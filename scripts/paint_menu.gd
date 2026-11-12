extends Control

signal closed

const ACCENT := Color(1.0, 0.78, 0.3)
const PANEL_BG := Color(0.055, 0.06, 0.075, 0.98)
const TEXT := Color(0.88, 0.9, 0.94)
const MUTED := Color(0.55, 0.6, 0.68)
const DARK_INK := Color(0.07, 0.07, 0.09)
const PANEL_WIDTH := 584.0
const SIDE := 20.0
const SWATCH_SIZE := 46
const COLUMNS := 10

var _car_id := ""
var _car_name := ""
var _car_node: Node3D
var _slot := 1
var _panel: PanelContainer
var _car_label: Label
var _finish_buttons := {}
var _slot_primary: Button
var _slot_secondary: Button
var _bicolor_check: CheckButton
var _palette_label: Label
var _grid: GridContainer
var _swatches: Array[Button] = []
var _status: Label
var _lock_panel: PanelContainer
var _unlock_button: Button
var _closing := false


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func open(car_id: String, car_name: String, car_node: Node3D) -> void:
	_car_id = car_id
	_car_name = car_name
	_car_node = car_node
	_slot = 1
	_closing = false
	_status.text = tr("La scelta viene salvata in automatico.")
	_status.add_theme_color_override("font_color", Color(0.45, 0.49, 0.57))
	_refresh_all()
	visible = true
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.16)


func close() -> void:
	if _closing or not visible:
		return
	_closing = true
	visible = false
	emit_signal("closed")


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _on_scrim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			close()


func _build_ui() -> void:
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0, 0, 0, 0.2)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.gui_input.connect(_on_scrim_input)
	add_child(scrim)

	_panel = PanelContainer.new()
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -PANEL_WIDTH - SIDE
	_panel.offset_right = -SIDE
	_panel.offset_top = SIDE
	_panel.offset_bottom = -SIDE
	_panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	content.add_child(header)

	var title := Label.new()
	title.text = tr("COLORI")
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", ACCENT)
	title.add_theme_color_override("font_shadow_color", Color(1, 0.55, 0.1, 0.35))
	title.add_theme_constant_override("shadow_offset_y", 2)
	header.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	var close_x := Button.new()
	close_x.text = "X"
	close_x.focus_mode = Control.FOCUS_NONE
	close_x.custom_minimum_size = Vector2(38, 34)
	close_x.add_theme_font_size_override("font_size", 18)
	close_x.add_theme_color_override("font_color", MUTED)
	close_x.add_theme_color_override("font_hover_color", ACCENT)
	_apply_flat_button(close_x)
	close_x.pressed.connect(close)
	header.add_child(close_x)

	_car_label = Label.new()
	_car_label.add_theme_font_size_override("font_size", 14)
	_car_label.add_theme_color_override("font_color", MUTED)
	content.add_child(_car_label)

	content.add_child(_section_label(tr("FINITURA")))

	var finish_row := HBoxContainer.new()
	finish_row.add_theme_constant_override("separation", 7)
	content.add_child(finish_row)
	for key in CarPaint.FINISHES:
		var button := Button.new()
		button.text = tr(CarPaint.FINISH_LABELS[key])
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_on_finish_pressed.bind(key))
		finish_row.add_child(button)
		_finish_buttons[key] = button

	var bicolor_row := HBoxContainer.new()
	bicolor_row.add_theme_constant_override("separation", 8)
	content.add_child(bicolor_row)
	var bicolor_label := Label.new()
	bicolor_label.text = tr("BICOLORE")
	bicolor_label.add_theme_font_size_override("font_size", 12)
	bicolor_label.add_theme_color_override("font_color", MUTED)
	bicolor_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bicolor_row.add_child(bicolor_label)
	var bicolor_spacer := Control.new()
	bicolor_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bicolor_row.add_child(bicolor_spacer)
	_bicolor_check = CheckButton.new()
	_bicolor_check.focus_mode = Control.FOCUS_NONE
	_bicolor_check.add_theme_color_override("font_color", TEXT)
	_bicolor_check.toggled.connect(_on_bicolor_toggled)
	bicolor_row.add_child(_bicolor_check)

	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation", 8)
	content.add_child(slots)
	_slot_primary = _slot_button()
	_slot_primary.pressed.connect(_on_slot_pressed.bind(1))
	slots.add_child(_slot_primary)
	_slot_secondary = _slot_button()
	_slot_secondary.pressed.connect(_on_slot_pressed.bind(2))
	slots.add_child(_slot_secondary)

	_palette_label = _section_label(tr("COLORE 1"))
	content.add_child(_palette_label)

	var grid_wrap := Control.new()
	grid_wrap.custom_minimum_size = Vector2(0, 252)
	content.add_child(grid_wrap)

	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 5)
	_grid.add_theme_constant_override("v_separation", 5)
	grid_wrap.add_child(_grid)
	for entry in CarPaint.PALETTE:
		var swatch := Button.new()
		swatch.custom_minimum_size = Vector2(SWATCH_SIZE, SWATCH_SIZE)
		swatch.focus_mode = Control.FOCUS_NONE
		swatch.tooltip_text = tr(String(entry["name"]))
		swatch.pressed.connect(_on_swatch_pressed.bind(entry["color"]))
		_grid.add_child(swatch)
		_swatches.append(swatch)

	_lock_panel = PanelContainer.new()
	_lock_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lock_panel.add_theme_stylebox_override("panel", _lock_style())
	_lock_panel.visible = false
	grid_wrap.add_child(_lock_panel)

	var lock_margin := MarginContainer.new()
	lock_margin.add_theme_constant_override("margin_left", 20)
	lock_margin.add_theme_constant_override("margin_right", 20)
	lock_margin.add_theme_constant_override("margin_top", 12)
	lock_margin.add_theme_constant_override("margin_bottom", 12)
	_lock_panel.add_child(lock_margin)

	var lock_box := VBoxContainer.new()
	lock_box.alignment = BoxContainer.ALIGNMENT_CENTER
	lock_box.add_theme_constant_override("separation", 8)
	lock_margin.add_child(lock_box)

	var lock_title := Label.new()
	lock_title.text = tr("COLORI BLOCCATI")
	lock_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_title.add_theme_font_size_override("font_size", 20)
	lock_title.add_theme_color_override("font_color", ACCENT)
	lock_box.add_child(lock_title)

	var lock_desc := Label.new()
	lock_desc.text = tr("Sblocca i 48 colori e le 4 finiture per questa auto.\nL'acquisto e' permanente e resta salvato.")
	lock_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lock_desc.add_theme_font_size_override("font_size", 13)
	lock_desc.add_theme_color_override("font_color", MUTED)
	lock_box.add_child(lock_desc)

	var unlock_spacer := Control.new()
	unlock_spacer.custom_minimum_size = Vector2(0, 4)
	lock_box.add_child(unlock_spacer)

	_unlock_button = Button.new()
	_unlock_button.custom_minimum_size = Vector2(0, 46)
	_unlock_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_unlock_button.focus_mode = Control.FOCUS_NONE
	_unlock_button.add_theme_font_size_override("font_size", 15)
	_unlock_button.pressed.connect(_on_unlock_pressed)
	_style_action_button(_unlock_button, true)
	lock_box.add_child(_unlock_button)

	_status = Label.new()
	_status.text = tr("La scelta viene salvata in automatico.")
	_status.add_theme_font_size_override("font_size", 11)
	_status.add_theme_color_override("font_color", Color(0.45, 0.49, 0.57))
	content.add_child(_status)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	content.add_child(footer)
	var reset_button := Button.new()
	reset_button.text = tr("Originale")
	reset_button.custom_minimum_size = Vector2(150, 40)
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.add_theme_font_size_override("font_size", 14)
	reset_button.pressed.connect(_on_reset_pressed)
	_style_action_button(reset_button, false)
	footer.add_child(reset_button)
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	var close_button := Button.new()
	close_button.text = tr("Chiudi")
	close_button.custom_minimum_size = Vector2(140, 40)
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_size_override("font_size", 15)
	close_button.pressed.connect(close)
	_style_action_button(close_button, true)
	footer.add_child(close_button)


func _section_label(text: String) -> Label:
	var label := Label.new()
	label.text = tr(text)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.62, 0.66, 0.74))
	return label


func _slot_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	return button


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = Color(1.0, 0.78, 0.3, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0, 0, 0, 0.55)
	style.shadow_size = 18
	return style


func _lock_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.085, 0.08, 0.065, 0.98)
	style.border_color = Color(1.0, 0.78, 0.3, 0.55)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style


func _apply_flat_button(button: Button) -> void:
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, empty)


func _style_action_button(button: Button, accent: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.14, 0.115, 0.06) if accent else Color(0.11, 0.12, 0.15)
	normal.border_color = ACCENT if accent else Color(1, 1, 1, 0.16)
	normal.set_border_width_all(2 if accent else 1)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.21, 0.17, 0.08) if accent else Color(0.16, 0.17, 0.21)
	for state in ["normal", "focus"]:
		button.add_theme_stylebox_override(state, normal)
	for state in ["hover", "pressed", "hover_pressed"]:
		button.add_theme_stylebox_override(state, hover)
	button.add_theme_color_override("font_color", ACCENT if accent else TEXT)
	button.add_theme_color_override("font_hover_color", Color(1, 0.9, 0.65) if accent else Color(1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 0.9, 0.65) if accent else Color(1, 1, 1))


func _style_finish_button(button: Button, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.22, 0.17, 0.07) if selected else Color(0.11, 0.12, 0.15)
	normal.border_color = ACCENT if selected else Color(1, 1, 1, 0.12)
	normal.set_border_width_all(2 if selected else 1)
	normal.set_corner_radius_all(9)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.28, 0.22, 0.1) if selected else Color(0.17, 0.18, 0.23)
	for state in ["normal", "focus"]:
		button.add_theme_stylebox_override(state, normal)
	for state in ["hover", "pressed", "hover_pressed"]:
		button.add_theme_stylebox_override(state, hover)
	button.add_theme_color_override("font_color", ACCENT if selected else TEXT)
	button.add_theme_color_override("font_hover_color", Color(1, 0.9, 0.65) if selected else Color(1, 1, 1))
	button.add_theme_color_override("font_disabled_color", Color(0.4, 0.42, 0.48))


func _style_swatch(button: Button, color: Color, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.border_color = ACCENT if selected else Color(0, 0, 0, 0.45)
	normal.set_border_width_all(3 if selected else 1)
	normal.set_corner_radius_all(6)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.border_color = Color(1, 1, 1, 1)
	hover.set_border_width_all(2)
	for state in ["normal", "focus"]:
		button.add_theme_stylebox_override(state, normal)
	for state in ["hover", "pressed", "hover_pressed"]:
		button.add_theme_stylebox_override(state, hover)
	button.text = "✓" if selected else ""
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override(
		"font_color", DARK_INK if color.get_luminance() > 0.55 else Color(1, 1, 1)
	)


func _style_slot(button: Button, color: Color, active: bool, enabled: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = ACCENT if active else Color(1, 1, 1, 0.2)
	style.set_border_width_all(3 if active else 1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	var hover := style.duplicate() as StyleBoxFlat
	hover.border_color = Color(1, 1, 1, 0.85)
	for state in ["normal", "focus", "hover", "pressed", "hover_pressed"]:
		button.add_theme_stylebox_override(state, style if state in ["normal", "focus"] else hover)
	var ink := DARK_INK if color.get_luminance() > 0.55 else Color(1, 1, 1)
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", ink)
	button.add_theme_color_override("font_pressed_color", ink)
	button.disabled = not enabled
	button.modulate.a = 1.0 if enabled else 0.45


func _on_swatch_pressed(color: Color) -> void:
	if _car_id == "" or not CarPaint.unlocked(_car_id):
		return
	if _slot == 1:
		CarPaint.set_primary_color(_car_id, color)
	else:
		CarPaint.set_secondary_color(_car_id, color)
	CarPaint.apply(_car_node, _car_id)
	_refresh_all()


func _on_finish_pressed(key: String) -> void:
	if _car_id == "" or not CarPaint.unlocked(_car_id):
		return
	CarPaint.set_finish(_car_id, key)
	CarPaint.apply(_car_node, _car_id)
	_refresh_all()


func _on_bicolor_toggled(enabled: bool) -> void:
	if _car_id == "" or not CarPaint.unlocked(_car_id):
		return
	CarPaint.set_two_tone(_car_id, enabled)
	CarPaint.apply(_car_node, _car_id)
	_refresh_all()


func _on_slot_pressed(slot: int) -> void:
	if not CarPaint.unlocked(_car_id):
		return
	if slot == 2 and not CarPaint.two_tone(_car_id):
		return
	_slot = slot
	_refresh_all()


func _on_reset_pressed() -> void:
	if _car_id == "":
		return
	CarPaint.reset_car(_car_id)
	CarPaint.apply(_car_node, _car_id)
	_refresh_all()


func _on_unlock_pressed() -> void:
	if _car_id == "" or CarPaint.unlocked(_car_id):
		return
	var cost := CarPaint.UNLOCK_COST
	if Garage.spend_gold(cost):
		CarPaint.unlock(_car_id)
		_status.text = tr("Colori sbloccati per questa auto: la scelta resta salvata.")
		_status.add_theme_color_override("font_color", ACCENT)
		_refresh_all()
	else:
		_status.text = tr(
			"CR Gold insufficienti: ne servono %d. Vinci le gare per guadagnarli."
		) % cost
		_status.add_theme_color_override("font_color", Color(1.0, 0.45, 0.38))


func _refresh_all() -> void:
	if _car_id == "":
		return
	var unlocked := CarPaint.unlocked(_car_id)
	var state := CarPaint.paint_for(_car_id)
	var stock := String(state["finish"]) == CarPaint.FINISH_STOCK
	_car_label.text = "%s   ·   %s" % [_car_name, Garage.format_gold(Garage.gold)]
	var enabled_finish := String(state["finish"])
	for key in _finish_buttons:
		var button: Button = _finish_buttons[key]
		button.set_pressed_no_signal(enabled_finish == key)
		button.disabled = not unlocked
		_style_finish_button(button, enabled_finish == key)

	_bicolor_check.set_pressed_no_signal(bool(state["two_tone"]))
	_bicolor_check.disabled = stock or not unlocked

	_style_slot(_slot_primary, state["primary"], _slot == 1, unlocked)
	_style_slot(
		_slot_secondary, state["secondary"], _slot == 2, unlocked and bool(state["two_tone"])
	)
	_slot_primary.text = tr("PRINCIPALE")
	_slot_secondary.text = (
		tr("SECONDARIO") if bool(state["two_tone"]) else tr("SECONDARIO (off)")
	)
	if not bool(state["two_tone"]) and _slot == 2:
		_slot = 1
	_palette_label.text = tr("COLORE 1") if _slot == 1 else tr("COLORE 2")

	_lock_panel.visible = not unlocked
	_grid.visible = unlocked
	_unlock_button.text = tr("Sblocca colori · %d CR Gold") % CarPaint.UNLOCK_COST

	var active_color: Color = state["primary"] if _slot == 1 else state["secondary"]
	for i in _swatches.size():
		var entry: Dictionary = CarPaint.PALETTE[i]
		var color: Color = entry["color"]
		var selected: bool = color.is_equal_approx(active_color) and not stock
		_style_swatch(_swatches[i], color, selected)
