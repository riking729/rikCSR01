shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 deep_color : source_color = vec3(0.025, 0.16, 0.28);
uniform vec3 shallow_color : source_color = vec3(0.06, 0.38, 0.52);
uniform vec3 horizon_color : source_color = vec3(0.55, 0.76, 0.95);
uniform vec3 sparkle_color : source_color = vec3(1.0, 0.95, 0.78);
uniform float night = 0.0;

varying vec3 world_pos;


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}


void fragment() {
	vec3 to_cam = CAMERA_POSITION_WORLD - world_pos;
	float dist = length(to_cam.xz);
	float ripple = sin(world_pos.x * 0.55 + TIME * 1.4) * sin(world_pos.z * 0.37 - TIME * 1.1);
	float ripple2 = sin(world_pos.x * 2.1 - world_pos.z * 0.9 + TIME * 2.3) * 0.5 + 0.5;
	float sparkle = smoothstep(0.55, 1.0, ripple * 0.45 + ripple2 * 0.55);
	sparkle *= 1.0 - smoothstep(60.0, 520.0, dist);

	vec3 base = mix(shallow_color, deep_color, smoothstep(8.0, 300.0, dist));
	base = mix(base, horizon_color, smoothstep(260.0, 900.0, dist) * (1.0 - night * 0.55));

	ALBEDO = base;
	ROUGHNESS = mix(0.18, 0.3, night);
	METALLIC = 0.0;
	SPECULAR = 0.55;
	EMISSION = sparkle_color * sparkle * (0.06 + night * 0.5);
}
