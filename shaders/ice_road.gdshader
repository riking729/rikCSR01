shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 ice_color : source_color = vec3(0.3, 0.48, 0.72);
uniform vec3 ice_deep : source_color = vec3(0.08, 0.18, 0.36);
uniform vec3 crack_color : source_color = vec3(0.6, 0.78, 0.94);
uniform vec3 sparkle_color : source_color = vec3(0.8, 0.92, 1.0);
uniform float reflectivity : hint_range(0.0, 1.0) = 0.28;
uniform float sparkle_strength = 0.35;

varying vec3 world_pos;


float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


float noise2(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


void fragment() {
	vec2 uv = world_pos.xz * 0.4;
	float broad = noise2(uv * 0.6);
	float fine = noise2(uv * 5.0);
	float crack = smoothstep(0.78, 0.95, noise2(uv * 1.6));
	float streak = smoothstep(0.72, 1.0, sin(uv.y * 3.0 + broad * 5.0) * 0.5 + 0.5) * 0.12;

	vec3 base = mix(ice_deep, ice_color, clamp(broad * 1.2 + fine * 0.25, 0.0, 1.0));
	base = mix(base, crack_color, clamp(crack * 0.4 + streak, 0.0, 1.0));

	ALBEDO = base;
	METALLIC = reflectivity;
	ROUGHNESS = 0.12 + broad * 0.12 + crack * 0.1;
	SPECULAR = 0.7;

	float glint = step(0.9935, hash21(floor(world_pos.xz * 30.0) + floor(TIME * 1.6)));
	EMISSION = sparkle_color * glint * sparkle_strength;
}
