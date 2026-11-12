extends Control

const Ladder := preload("res://scripts/series_ladder.gd")
const ACCENT := Color(1.0, 0.78, 0.3)
const TAB_SELECTED_BG := Color(0.16, 0.13, 0.07)
const TAB_BG := Color(0.08, 0.08, 0.09)
const TAB_BORDER := Color(0.32, 0.32, 0.35)

@onready var back_button: Button = %BackButton
@onready var choose_car_button: Button = %ChooseCarButton
@onready var start_button: Button = %StartButton
@onready var series_tabs: HBoxContainer = %SeriesTabs
@onready var series_title: Label = %SeriesTitle
@onready var series_info: Label = %SeriesInfo
@onready var ladder_scroll: ScrollContainer = %LadderScroll
@onready var ladder: Control = %Ladder

var _group := ButtonGroup.new()
var _buttons := {}
var _series_id := ""
var _race_count := 0
var _won := 0
var _time := 0.0


func _ready() -> void:
	_build_tabs()
	_style_header_buttons()
	var initial: String = Series.selected_id
	if not _buttons.has(initial):
		initial = Series.SERIES[0]["id"]
	_select(initial)
	AudioManager.connect_button_sfx(self)
	if start_button.disabled:
		back_button.grab_focus()
	else:
		start_button.grab_focus()


func _process(delta: float) -> void:
	_time += delta
	for node in ladder.nodes:
		if node.state == "current":
			node.pulse = 0.5 + 0.5 * sin(_time * 4.0)
			node.queue_redraw()


func _build_tabs() -> void:
	for entry in Series.SERIES:
		var id: String = entry["id"]
		var button := Button.new()
		button.text = tr(str(entry["name"]))
		button.toggle_mode = true
		button.button_group = _group
		button.custom_minimum_size = Vector2(0, 44)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_on_series_pressed.bind(id))
		series_tabs.add_child(button)
		_buttons[id] = button


func _style_header_buttons() -> void:
	back_button.add_theme_font_size_override("font_size", 22)
	choose_car_button.add_theme_font_size_override("font_size", 15)
	start_button.add_theme_font_size_override("font_size", 17)
	for button in [back_button, choose_car_button, start_button]:
		var style := StyleBoxFlat.new()
		style.bg_color = TAB_BG
		style.border_color = TAB_BORDER
		style.set_border_width_all(2)
		style.set_corner_radius_all(10)
		for state in ["normal", "hover", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, style)


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
	style.bg_color = TAB_SELECTED_BG if selected else TAB_BG
	style.border_color = ACCENT if selected else TAB_BORDER
	style.set_border_width_all(3 if selected else 1)
	style.set_corner_radius_all(10)
	for state in ["normal", "hover", "pressed", "hover_pressed"]:
		button.add_theme_stylebox_override(state, style)


func _refresh() -> void:
	_series_id = Series.selected_id
	_race_count = Series.race_count(_series_id)
	_won = Series.progress(_series_id)
	series_title.text = tr(str(Series.find(_series_id)["name"]))
	choose_car_button.text = "%s\n%s" % [tr("Scegli auto"), tr(RaceConfig.player_name())]
	ladder.build(_race_count, _won, _make_node)
	if Series.is_completed(_series_id):
		start_button.text = tr("Serie completata")
		start_button.disabled = true
		series_info.text = tr("Serie completata: tutte le %d gare vinte · IA %s") % [
			_race_count, _ai_rating(_race_count - 1)
		]
	else:
		start_button.text = tr("Avvia gara %d") % (_won + 1)
		start_button.disabled = false
		series_info.text = tr("Prossima: Gara %d di %d · Premio %s + %s · IA %s") % [
			_won + 1, _race_count,
			Garage.format_credits(Series.prize(_series_id, _won)),
			Garage.format_gold(Series.gold_prize(_series_id, _won)),
			_ai_rating(_won),
		]
	_scroll_to_current.call_deferred()


func _make_node(index: int) -> Control:
	var state := "locked"
	if index < _won:
		state = "won"
	elif index == _won:
		state = "current"
	var node := Ladder.LadderNode.new()
	node.setup(
		index, state,
		Garage.format_credits(Series.prize(_series_id, index)),
		Garage.format_gold(Series.gold_prize(_series_id, index))
	)
	return node


func _scroll_to_current() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if _won >= _race_count or ladder_scroll.size.x <= 0:
		ladder_scroll.scroll_horizontal = 0
		return
	var node_x := 24.0 + _won * (Ladder.NODE_SIZE.x + Ladder.NODE_GAP)
	var target := node_x - (ladder_scroll.size.x - Ladder.NODE_SIZE.x) * 0.5
	var max_scroll := maxf(0.0, ladder.size.x - ladder_scroll.size.x)
	ladder_scroll.scroll_horizontal = int(clampf(target, 0.0, max_scroll))


func _ai_rating(index: int) -> String:
	var multiplier := Settings.ai_multiplier() * (1.0 + Series.difficulty(_series_id, index))
	return Settings.format_ai_rating(multiplier)


func _on_series_pressed(id: String) -> void:
	_select(id)


func _on_start_button_pressed() -> void:
	if Series.is_completed(Series.selected_id):
		return
	Series.begin(Series.selected_id)
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_choose_car_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/CarSelect.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/CarTune.tscn")
