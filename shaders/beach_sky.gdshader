shader_type sky;

uniform bool night = false;
uniform vec3 day_top : source_color = vec3(0.20, 0.48, 0.92);
uniform vec3 day_horizon : source_color = vec3(0.74, 0.89, 1.0);
uniform vec3 night_top : source_color = vec3(0.015, 0.025, 0.075);
uniform vec3 night_horizon : source_color = vec3(0.09, 0.13, 0.24);
uniform vec3 moon_dir = vec3(-0.5, 0.235, -0.72);
uniform vec3 moon_color : source_color = vec3(1.0, 0.97, 0.9);
uniform float moon_size = 0.99965;
uniform float moon_brightness = 2.2;
uniform float moon_halo = 1.0;


float hash31(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}


void sky() {
	vec3 dir = normalize(EYEDIR);
	float h = clamp(dir.y, 0.0, 1.0);
	vec3 col;
	if (night) {
		col = mix(night_horizon, night_top, pow(h, 0.55));

		vec3 cell = floor(dir * 220.0);
		float r = hash31(cell);
		float star = step(0.9965, r) * (1.0 - smoothstep(0.05, 0.35, h));
		float twinkle = 0.65 + 0.35 * sin(TIME * 2.0 + r * 120.0);
		col += vec3(1.0, 0.96, 0.85) * star * twinkle * 1.6;

		float d = dot(dir, normalize(moon_dir));
		float disc = smoothstep(moon_size - 0.00025, moon_size + 0.0001, d);
		float halo = pow(max(d, 0.0), 900.0) * 0.35 + pow(max(d, 0.0), 60.0) * 0.04;
		col += moon_color * (disc * moon_brightness + halo * moon_halo);
	} else {
		col = mix(day_horizon, day_top, pow(h, 0.7));
		float sun = max(dot(dir, normalize(LIGHT0_DIRECTION)), 0.0);
		col += vec3(1.0, 0.92, 0.72) * pow(sun, 1200.0) * 4.0;
		col += vec3(1.0, 0.85, 0.6) * pow(sun, 12.0) * 0.18;
	}
	COLOR = col;
}
