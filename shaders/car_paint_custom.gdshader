shader_type spatial;
render_mode cull_back;

// The albedo is sampled raw (sRGB) so the paint mask thresholds match the
// offline analysis of the Grab3D atlases. Colors stay in sRGB until the end.
uniform sampler2D albedo_texture : hint_default_white, filter_linear_mipmap;
uniform sampler2D orm_texture : hint_default_white, filter_linear_mipmap;
uniform bool use_texture = false;

uniform float source_hue = 0.5;
uniform float hue_tolerance = 0.05;
uniform float min_saturation = 0.25;
uniform float max_saturation = 1.0;
uniform float min_value = 0.25;
uniform float body_reference = 0.8;

uniform vec4 primary_color = vec4(1.0);
uniform vec4 secondary_color = vec4(0.05, 0.05, 0.05, 1.0);
uniform bool two_tone = false;
uniform float split_height = 0.52;
uniform float split_softness = 0.035;
uniform float height_min = 0.0;
uniform float height_max = 1.0;

// 0 normale, 1 opaco, 2 metallizzato, 3 cromatico
uniform int finish = 0;

varying float local_height;

vec3 rgb_to_hsv(vec3 c) {
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
	return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

vec3 srgb_to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

void vertex() {
	local_height = (VERTEX.y - height_min) / max(height_max - height_min, 0.001);
}

void fragment() {
	vec3 tex_srgb = texture(albedo_texture, UV).rgb;
	vec3 tex_hsv = vec3(0.0);
	float paint_mask = 1.0;

	if (use_texture) {
		tex_hsv = rgb_to_hsv(tex_srgb);
		float hue_delta = abs(tex_hsv.x - source_hue);
		hue_delta = min(hue_delta, 1.0 - hue_delta);
		paint_mask = 1.0 - smoothstep(hue_tolerance * 0.65, hue_tolerance, hue_delta);
		paint_mask *= smoothstep(min_saturation - 0.06, min_saturation + 0.02, tex_hsv.y);
		if (max_saturation < 0.999) {
			paint_mask *= 1.0 - smoothstep(max_saturation - 0.06, max_saturation + 0.06, tex_hsv.y);
		}
		paint_mask *= smoothstep(min_value - 0.05, min_value + 0.03, tex_hsv.z);
		paint_mask = clamp(paint_mask, 0.0, 1.0);
	}

	float tone = two_tone
		? smoothstep(split_height - split_softness, split_height + split_softness, local_height)
		: 1.0;
	vec3 target_srgb = mix(secondary_color.rgb, primary_color.rgb, tone);
	vec3 target_hsv = rgb_to_hsv(target_srgb);

	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), VIEW), 0.0, 1.0), 2.2);
	if (finish == 3) {
		target_hsv.x = fract(target_hsv.x + fresnel * 0.32);
		target_hsv.y = clamp(target_hsv.y + fresnel * 0.18, 0.0, 1.0);
	}

	vec3 painted_srgb;
	if (use_texture) {
		float shade = clamp(tex_hsv.z / max(body_reference, 0.05), 0.50, 1.30);
		painted_srgb = hsv_to_rgb(vec3(
			target_hsv.x, target_hsv.y, clamp(target_hsv.z * shade, 0.0, 1.0)
		));
	} else {
		painted_srgb = hsv_to_rgb(target_hsv);
	}

	vec3 final_srgb = use_texture ? mix(tex_srgb, painted_srgb, paint_mask) : painted_srgb;
	ALBEDO = srgb_to_linear(final_srgb);

	if (use_texture) {
		vec3 orm = texture(orm_texture, UV).rgb;
		float trim_roughness = clamp(orm.g, 0.06, 1.0);
		float trim_metallic = orm.b;
		if (finish == 1) {
			ROUGHNESS = mix(trim_roughness, 0.95, paint_mask);
			METALLIC = mix(trim_metallic, 0.0, paint_mask);
			SPECULAR = 0.2;
		} else if (finish == 2) {
			ROUGHNESS = mix(trim_roughness, 0.28, paint_mask);
			METALLIC = mix(trim_metallic, 0.65, paint_mask);
			SPECULAR = 0.55;
		} else if (finish == 3) {
			ROUGHNESS = mix(trim_roughness, 0.26, paint_mask);
			METALLIC = mix(trim_metallic, 0.5, paint_mask);
			SPECULAR = 0.65;
		} else {
			ROUGHNESS = mix(trim_roughness, 0.38, paint_mask);
			METALLIC = mix(trim_metallic, 0.05, paint_mask);
			SPECULAR = 0.5;
		}
	} else {
		if (finish == 1) {
			ROUGHNESS = 0.95;
			METALLIC = 0.0;
			SPECULAR = 0.2;
		} else if (finish == 2) {
			ROUGHNESS = 0.28;
			METALLIC = 0.65;
			SPECULAR = 0.55;
		} else if (finish == 3) {
			ROUGHNESS = 0.26;
			METALLIC = 0.5;
			SPECULAR = 0.65;
		} else {
			ROUGHNESS = 0.38;
			METALLIC = 0.05;
			SPECULAR = 0.5;
		}
	}
}
