shader_type spatial;
render_mode blend_add, unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 beam_color : source_color = vec4(1.0, 0.92, 0.7, 1.0);
uniform float beam_strength = 0.18;

varying vec2 local;


void vertex() {
	local = VERTEX.xy;
}


void fragment() {
	float along = clamp((local.y + 3.5) / 7.0, 0.0, 1.0);
	float half_width = mix(0.18, 1.2, along);
	float edge = 1.0 - smoothstep(half_width * 0.45, half_width, abs(local.x));
	float fade = smoothstep(0.0, 0.12, along) * (1.0 - smoothstep(0.75, 1.0, along));
	ALBEDO = beam_color.rgb;
	ALPHA = edge * fade * beam_strength;
}
