shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 sand_color : source_color = vec3(0.86, 0.72, 0.40);
uniform vec3 streak_color : source_color = vec3(1.0, 0.88, 0.52);
uniform float streak_strength = 0.4;
uniform float night = 0.0;

varying vec3 world_pos;


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


void fragment() {
	float grain = hash21(floor(world_pos.xz * 10.0));
	float wind = sin(world_pos.x * 1.7 + world_pos.z * 0.12 - TIME * 0.9);
	float wind2 = sin(world_pos.x * 4.1 - world_pos.z * 0.5 + TIME * 1.7) * 0.5 + 0.5;
	float streak = smoothstep(0.7, 1.0, wind) * 0.7 + smoothstep(0.85, 1.0, wind2) * 0.5;
	streak *= streak_strength;

	vec3 sand = sand_color * (0.93 + grain * 0.1);
	ALBEDO = mix(sand, streak_color, clamp(streak, 0.0, 1.0));
	ROUGHNESS = 1.0;
	SPECULAR = 0.1;
	EMISSION = streak_color * streak * (0.02 + night * 0.12);
}
