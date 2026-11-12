shader_type spatial;

uniform vec4 wall_color : source_color = vec4(0.25, 0.3, 0.35, 1.0);
uniform vec4 window_color : source_color = vec4(1.0, 0.8, 0.35, 1.0);
uniform float floor_height = 3.4;
uniform float window_energy = 1.8;

instance uniform vec3 building_size = vec3(10.0, 20.0, 10.0);

varying vec3 world_position;
varying vec3 world_normal;


void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}


float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}


void fragment() {
	vec3 wall = wall_color.rgb;
	EMISSION = vec3(0.0);

	vec3 n = normalize(world_normal);
	if (abs(n.y) < 0.5) {
		vec3 center = MODEL_MATRIX[3].xyz;
		float horizontal;
		float face_width;
		if (abs(n.x) > 0.5) {
			horizontal = world_position.z - center.z;
			face_width = building_size.z;
		} else {
			horizontal = world_position.x - center.x;
			face_width = building_size.x;
		}

		float u = horizontal / face_width + 0.5;
		float col = u * 3.0;
		float row = (world_position.y - (center.y - building_size.y * 0.5)) / floor_height;
		float cu = fract(col);
		float rv = fract(row);

		if (cu > 0.27 && cu < 0.73 && rv > 0.3 && rv < 0.75) {
			float brightness = mix(0.8, 1.1, hash21(floor(vec2(col, row)) + center.xz));
			ALBEDO = window_color.rgb;
			EMISSION = window_color.rgb * window_energy * brightness;
			ROUGHNESS = 1.0;
		} else {
			ALBEDO = wall;
			ROUGHNESS = 0.9;
		}
	} else {
		ALBEDO = wall;
		ROUGHNESS = 0.9;
	}
}
