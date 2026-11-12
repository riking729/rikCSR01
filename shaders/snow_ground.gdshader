shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 snow_color : source_color = vec3(0.78, 0.87, 0.98);
uniform vec3 shade_color : source_color = vec3(0.52, 0.65, 0.85);
uniform vec3 sparkle_color : source_color = vec3(1.0, 1.0, 1.0);

varying vec3 world_pos;


float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


void fragment() {
	float grain = hash21(floor(world_pos.xz * 5.0));
	float drift = sin(world_pos.x * 0.35 + world_pos.z * 0.12) * 0.5 + 0.5;

	ALBEDO = mix(snow_color, shade_color, grain * 0.12 + drift * 0.08);
	ROUGHNESS = 0.8;
	SPECULAR = 0.3;

	float glint = step(0.9965, hash21(floor(world_pos.xz * 20.0) + floor(TIME * 1.4)));
	EMISSION = sparkle_color * glint * 0.35;
}
