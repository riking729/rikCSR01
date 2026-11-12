shader_type spatial;
render_mode cull_disabled;

uniform vec3 line_color : source_color = vec3(0.92, 0.92, 0.92);
uniform float dash_length = 3.0;
uniform float gap_length = 6.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float cycle = dash_length + gap_length;
	if (mod(world_position.z, cycle) > dash_length) {
		discard;
	}
	ALBEDO = line_color;
	ROUGHNESS = 0.6;
}
