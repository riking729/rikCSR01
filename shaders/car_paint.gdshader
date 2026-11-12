shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform float source_hue = 0.44;
uniform float hue_tolerance = 0.085;
uniform float min_saturation = 0.30;
uniform float target_hue = 0.075;
uniform float target_saturation = 0.88;

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

void fragment() {
	vec3 color = textureLod(albedo_texture, UV, 0.0).rgb;
	vec3 hsv = rgb_to_hsv(color);
	float hue_diff = abs(hsv.x - source_hue);
	hue_diff = min(hue_diff, 1.0 - hue_diff);
	if (hue_diff <= hue_tolerance && hsv.y >= min_saturation) {
		hsv.x = target_hue;
		hsv.y = target_saturation;
		color = hsv_to_rgb(hsv);
	}
	ALBEDO = color;
	ROUGHNESS = 0.75;
	SPECULAR = 0.4;
}
