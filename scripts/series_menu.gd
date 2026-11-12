extends Control

const ACCENT := Color(1.0, 0.78, 0.3)
const SELECTED_BG := Color(0.16, 0.13, 0.07)
const UNSELECTED_BG := Color(0.08, 0.08, 0.09)
const UNSELECTED_BORDER := Color(0.32, 0.32, 0.35)

@onready var series_buttons: GridContainer = %SeriesButtons
@onready var series_info: Label = %SeriesInfo
@onready var races_box: VBoxContainer = %Races
@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton

var _group := ButtonGroup.new()
var _buttons := {}


func _ready() -> void:
	_build_series_buttons()
	var initial: String = Series.selected_id
	if not _buttons.has(initial):
		initial = Series.SERIES[0]["id"]
	_select(initial)
	AudioManager.connect_button_sfx(self)
	if start_button.disabled:
		back_button.grab_focus()
	else:
		start_button.grab_focus()


func _build_series_buttons() -> void:
	for entry in Series.SERIES:
		var id: String = entry["id"]
		var button := Button.new()
		button.text = tr(str(entry["name"]))
		button.toggle_mode = true
		button.button_group = _group
		button.custom_minimum_size = Vector2(0, 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(_on_series_pressed.bind(id))
		series_buttons.add_child(button)
		_buttons[id] = button


func _select(id: String) -> void:
	Series.selected_id = id
	for series_id in _buttons:
		var button: Button = _buttons[series_id]
		var selected: bool = series_id == id
		button.set_pressed_no_signal(selected)
		_apply_style(button, selected)
	_refresh()


func _apply_style(button: Button, selected: bool) -> void:
	var text_color := ACCENT if selected else Color(0.85, 0.85, 0.88)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_hover_pressed_color", text_color)

	var style := StyleBoxFlat.new()
	style.bg_color = SELECTED_BG if selected else UNSELECTED_BG
	style.border_color = ACCENT if selected else UNSELECTED_BORDER
	style.set_border_width_all(3 if selected else 1)
	style.set_corner_radius_all(12)
	for state in ["normal", "hover", "pressed", "hover_pressed"]:
		button.add_theme_stylebox_override(state, style)


func _refresh() -> void:
	var id := Series.selected_id
	var count := Series.race_count(id)
	var won := Series.progress(id)

	if Series.is_completed(id):
		series_info.text = tr("Serie completata: tutte le %d gare vinte · IA %s") % [
			count, _ai_rating(id, count - 1)
		]
		start_button.text = tr("Serie completata")
		start_button.disabled = true
	else:
		series_info.text = tr("Prossima: Gara %d di %d · Premio %s + %s · IA %s") % [
			won + 1, count, Garage.format_credits(Series.prize(id, won)),
			Garage.format_gold(Series.gold_prize(id, won)), _ai_rating(id, won)
		]
		start_button.text = tr("Avvia gara %d") % (won + 1)
		start_button.disabled = false

	for child in races_box.get_children():
		races_box.remove_child(child)
		child.queue_free()

	for i in count:
		races_box.add_child(_build_race_row(id, i, won))


func _build_race_row(id: String, index: int, won: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var name_label := Label.new()
	name_label.text = tr("Gara %d") % (index + 1)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)

	var prize_label := Label.new()
	prize_label.text = "%s · +%s" % [
		Garage.format_credits(Series.prize(id, index)),
		Garage.format_gold(Series.gold_prize(id, index)),
	]
	prize_label.add_theme_color_override("font_color", Color(0.82, 0.85, 0.92))
	prize_label.add_theme_font_size_override("font_size", 16)
	row.add_child(prize_label)

	var ai_label := Label.new()
	ai_label.text = tr("IA %s") % _ai_rating(id, index)
	ai_label.custom_minimum_size = Vector2(90, 0)
	ai_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ai_label.add_theme_color_override("font_color", Color(0.72, 0.76, 0.84))
	ai_label.add_theme_font_size_override("font_size", 14)
	row.add_child(ai_label)

	var status_label := Label.new()
	status_label.custom_minimum_size = Vector2(120, 0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_font_size_override("font_size", 14)
	if index < won:
		status_label.text = tr("VINTA")
		status_label.add_theme_color_override("font_color", ACCENT)
	elif index == won:
		status_label.text = tr("DA CORRERE")
		status_label.add_theme_color_override("font_color", Color(0.92, 0.94, 1))
	else:
		status_label.text = tr("BLOCCATA")
		status_label.add_theme_color_override("font_color", Color(0.42, 0.46, 0.54))
	row.add_child(status_label)

	return row


func _ai_rating(id: String, index: int) -> String:
	var multiplier := Settings.ai_multiplier() * (1.0 + Series.difficulty(id, index))
	return Settings.format_ai_rating(multiplier)


func _on_series_pressed(id: String) -> void:
	_select(id)


func _on_start_button_pressed() -> void:
	if Series.is_completed(Series.selected_id):
		return
	Series.begin(Series.selected_id)
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/CarTune.tscn")
