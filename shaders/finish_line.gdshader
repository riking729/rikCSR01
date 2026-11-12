shader_type spatial;
render_mode unshaded;

uniform vec2 squares = vec2(16.0, 3.0);
uniform vec3 color_a : source_color = vec3(0.04, 0.04, 0.05);
uniform vec3 color_b : source_color = vec3(0.92, 0.92, 0.92);

void fragment() {
	vec2 cell = floor(UV * squares);
	float checker = mod(cell.x + cell.y, 2.0);
	ALBEDO = mix(color_a, color_b, checker);
}
