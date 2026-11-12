extends Control

const SHIFT_REVS := 0.85
const GAUGE_START := deg_to_rad(135.0)
const GAUGE_END := deg_to_rad(405.0)

const NITRO_BLUE := Color(0.22, 0.56, 1.0)
const TEXT_MAIN := Color(0.96, 0.97, 1.0)
const TEXT_SOFT := Color(0.66, 0.71, 0.8)
const ACCENT := Color(1.0, 0.78, 0.3)
const RED_ZONE := Color(1.0, 0.3, 0.22)

var _speed_kmh := 0.0
var _revs := 0.0
var _nitro := 100.0
var _gear := 1
var _top_gear := 6
var _started := false
var _time := 0.0

var _panel_style: StyleBoxFlat
var _chip_style: StyleBoxFlat
var _prompt_style: StyleBoxFlat


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color(0.045, 0.05, 0.07, 1.0)
	_panel_style.set_corner_radius_all(12)
	_panel_style.set_border_width_all(1)
	_panel_style.border_color = Color(1.0, 1.0, 1.0, 0.07)

	_chip_style = StyleBoxFlat.new()
	_chip_style.bg_color = Color(0.09, 0.11, 0.15, 0.95)
	_chip_style.set_corner_radius_all(5)
	_chip_style.set_border_width_all(1)
	_chip_style.border_color = Color(0.35, 0.4, 0.5, 0.6)

	_prompt_style = StyleBoxFlat.new()
	_prompt_style.bg_color = Color(0.04, 0.03, 0.02, 0.82)
	_prompt_style.set_corner_radius_all(8)
	_prompt_style.set_border_width_all(1)
	_prompt_style.border_color = Color(1.0, 0.55, 0.2, 0.5)


func update_state(
	speed_kmh: float,
	revs: float,
	nitro: float,
	gear: int,
	top_gear: int,
	started: bool
) -> void:
	_speed_kmh = speed_kmh
	_revs = clampf(revs, 0.0, 1.0)
	_nitro = clampf(nitro, 0.0, 100.0)
	_gear = gear
	_top_gear = top_gear
	_started = started


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var tach_center := Vector2(size.x - 172.0, size.y - 140.0)
	var tach_radius := 110.0
	var nitro_center := Vector2(size.x - 404.0, size.y - 116.0)
	var nitro_radius := 66.0

	_draw_controls()
	_draw_tach(tach_center, tach_radius)
	_draw_nitro(nitro_center, nitro_radius)
	_draw_shift_prompt(tach_center, tach_radius)


func _draw_tach(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, Color(0.035, 0.045, 0.065, 0.92))
	draw_arc(center, radius, GAUGE_START, GAUGE_END, 96, Color(0.15, 0.17, 0.22), 12.0, true)
	draw_arc(center, radius, _angle_at(SHIFT_REVS), GAUGE_END, 40, RED_ZONE, 12.0, true)

	for i in 9:
		var t := float(i) / 8.0
		var direction := Vector2.from_angle(_angle_at(t))
		var long_tick := i % 2 == 0
		draw_line(
			center + direction * (radius - (26.0 if long_tick else 20.0)),
			center + direction * (radius - 12.0),
			Color(0.82, 0.85, 0.92, 0.95),
			3.0 if long_tick else 2.0,
			true
		)

	var needle_color := RED_ZONE if _revs >= SHIFT_REVS else ACCENT
	var needle_direction := Vector2.from_angle(_angle_at(_revs))
	draw_line(
		center + needle_direction * (radius * 0.3),
		center + needle_direction * (radius - 24.0),
		needle_color,
		4.0,
		true
	)
	draw_circle(center, 7.0, Color(0.08, 0.09, 0.12))
	draw_circle(center, 4.0, needle_color)

	_draw_label("GIRI", center + Vector2(0.0, -58.0), 11, TEXT_SOFT)
	_draw_label(str(roundi(_speed_kmh)), center + Vector2(0.0, 30.0), 38, TEXT_MAIN)
	_draw_label("km/h", center + Vector2(0.0, 56.0), 13, TEXT_SOFT)
	_draw_label("MARCIA %d/%d" % [_gear, _top_gear], center + Vector2(0.0, 84.0), 15, ACCENT)


func _draw_nitro(center: Vector2, radius: float) -> void:
	var ratio := _nitro / 100.0
	draw_circle(center, radius, Color(0.035, 0.045, 0.065, 0.92))
	draw_arc(center, radius, GAUGE_START, GAUGE_END, 96, Color(0.15, 0.17, 0.22), 10.0, true)

	if ratio > 0.002:
		var end_angle := _angle_at(ratio)
		draw_arc(
			center, radius, GAUGE_START, end_angle, 64,
			Color(NITRO_BLUE.r, NITRO_BLUE.g, NITRO_BLUE.b, 0.2), 17.0, true
		)
		draw_arc(center, radius, GAUGE_START, end_angle, 64, NITRO_BLUE, 9.0, true)

	for i in 5:
		var direction := Vector2.from_angle(_angle_at(float(i) / 4.0))
		draw_line(
			center + direction * (radius - 19.0),
			center + direction * (radius - 10.0),
			Color(0.8, 0.88, 1.0, 0.7),
			2.0,
			true
		)

	var needle_direction := Vector2.from_angle(_angle_at(ratio))
	draw_line(
		center + needle_direction * (radius * 0.45),
		center + needle_direction * (radius - 16.0),
		Color(0.6, 0.82, 1.0),
		3.0,
		true
	)
	draw_circle(center, 5.0, NITRO_BLUE)

	_draw_label("NITRO", center + Vector2(0.0, -20.0), 12, Color(0.6, 0.78, 1.0))
	_draw_label("%d%%" % roundi(_nitro), center + Vector2(0.0, 8.0), 24, TEXT_MAIN)


func _draw_shift_prompt(tach_center: Vector2, tach_radius: float) -> void:
	if not _started or _gear >= _top_gear or _revs < SHIFT_REVS:
		return
	var pulse := 0.55 + 0.45 * absf(sin(_time * 4.5))
	var text_size := ThemeDB.fallback_font.get_string_size(
		"CAMBIA MARCIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 22
	)
	var center := Vector2(tach_center.x, tach_center.y - tach_radius - 52.0)
	var panel := Rect2(
		center - Vector2(text_size.x * 0.5 + 20.0, 30.0),
		Vector2(text_size.x + 40.0, 64.0)
	)
	draw_style_box(_prompt_style, panel)
	_draw_label("CAMBIA MARCIA", center, 22, Color(1.0, 0.55, 0.2, pulse))
	_draw_label("SPAZIO", center + Vector2(0.0, 24.0), 15, Color(1.0, 0.85, 0.5, pulse))


func _draw_controls() -> void:
	var font := ThemeDB.fallback_font
	var panel := Rect2(22.0, size.y - 202.0, 296.0, 178.0)
	draw_style_box(_panel_style, panel)

	var left := panel.position.x + 16.0
	draw_string(
		font,
		Vector2(left, panel.position.y + 22.0),
		"COMANDI",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		12,
		Color(0.55, 0.62, 0.72)
	)

	var row_y := panel.position.y + 40.0
	for entry in _control_rows():
		var key: String = entry[0]
		var action: String = entry[1]
		var key_size := font.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
		var chip := Rect2(left, row_y, maxf(key_size.x + 16.0, 44.0), 19.0)
		draw_style_box(_chip_style, chip)
		draw_string(
			font,
			Vector2(chip.position.x + (chip.size.x - key_size.x) * 0.5, chip.position.y + 13.0),
			key,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			13,
			Color(1.0, 0.86, 0.5)
		)
		draw_string(
			font,
			Vector2(left + 96.0, row_y + 13.0),
			action,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			Color(0.82, 0.85, 0.92)
		)
		row_y += 25.0


func _control_rows() -> Array:
	return [
		[_keys_text("accelerate"), "Accelera"],
		[_keys_text("brake"), "Freno"],
		[_keys_text("shift_gear"), "Cambia marcia"],
		[_keys_text("nitro"), "Nitro"],
		["ESC", "Menu"],
	]


func _keys_text(action: String) -> String:
	var parts: Array[String] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			parts.append(_key_text((event as InputEventKey).physical_keycode))
	return " / ".join(parts) if not parts.is_empty() else "-"


func _key_text(code: Key) -> String:
	match code:
		KEY_UP:
			return "\u2191"
		KEY_DOWN:
			return "\u2193"
		KEY_LEFT:
			return "\u2190"
		KEY_RIGHT:
			return "\u2192"
		KEY_SPACE:
			return "SPAZIO"
		KEY_ESCAPE:
			return "ESC"
		KEY_NONE:
			return "-"
	return OS.get_keycode_string(code).to_upper()


func _angle_at(ratio: float) -> float:
	return lerpf(GAUGE_START, GAUGE_END, ratio)


func _draw_label(text: String, center: Vector2, font_size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var position := Vector2(
		center.x - text_size.x * 0.5,
		center.y - text_size.y * 0.5 + font.get_ascent(font_size)
	)
	draw_string(
		font,
		position + Vector2(0.0, 2.0),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		Color(0.0, 0.0, 0.0, color.a * 0.7)
	)
	draw_string(
		font,
		position,
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		color
	)
