extends Control

const LABEL_WIDTH := 170.0
const LEVEL_WIDTH := 90.0
const COST_WIDTH := 170.0
const BAR_COLORS := {
	"top_speed": Color(0.91, 0.32, 0.29),
	"transmission": Color(0.29, 0.56, 0.91),
	"nos": Color(0.22, 0.78, 0.85),
}

@onready var car_label: Label = %CarLabel
@onready var opponent_label: Label = %OpponentLabel
@onready var credits_label: Label = %CreditsLabel
@onready var stats_box: VBoxContainer = %Stats
@onready var message_label: Label = %Message
@onready var start_button: Button = %StartButton
@onready var series_button: Button = %SeriesButton
@onready var back_button: Button = %BackButton

var _rows := {}


func _ready() -> void:
	if not Garage.is_owned(RaceConfig.player_car):
		get_tree().change_scene_to_file("res://scenes/CarSelect.tscn")
		return
	car_label.text = RaceConfig.player_name()
	var ai_multiplier := Settings.ai_multiplier()
	if Series.is_active():
		RaceConfig.pick_opponent()
		ai_multiplier *= 1.0 + Series.active_difficulty()
	opponent_label.text = tr("Avversario: %s · Livello %d · IA %s") % [
		tr(RaceConfig.opponent_name()), RaceConfig.duel_level(RaceConfig.player_car),
		Settings.format_ai_rating(ai_multiplier)
	]
	_build_rows()
	_refresh()
	AudioManager.connect_button_sfx(self)
	if Series.is_active():
		series_button.grab_focus()
	else:
		start_button.grab_focus()


func _build_rows() -> void:
	for stat in Garage.STATS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)

		var name_label := Label.new()
		name_label.text = tr(Garage.STAT_NAMES[stat])
		name_label.custom_minimum_size = Vector2(LABEL_WIDTH, 0)
		name_label.add_theme_font_size_override("font_size", 18)
		row.add_child(name_label)

		var bar := ProgressBar.new()
		bar.max_value = 100.0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 22)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_style_bar(bar, BAR_COLORS[stat])
		row.add_child(bar)

		var level_label := Label.new()
		level_label.custom_minimum_size = Vector2(LEVEL_WIDTH, 0)
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		level_label.add_theme_font_size_override("font_size", 16)
		row.add_child(level_label)

		var upgrade_button := Button.new()
		upgrade_button.custom_minimum_size = Vector2(COST_WIDTH, 44)
		upgrade_button.pressed.connect(_on_upgrade_pressed.bind(stat))
		row.add_child(upgrade_button)

		stats_box.add_child(row)
		_rows[stat] = {"bar": bar, "level": level_label, "button": upgrade_button}


func _style_bar(bar: ProgressBar, color: Color) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.09, 0.09, 0.11)
	background.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)


func _refresh() -> void:
	var car := RaceConfig.player_car
	credits_label.text = tr("Crediti: %s   ·   %s") % [
		Garage.format_credits(Garage.credits), Garage.format_gold(Garage.gold)
	]
	for stat in Garage.STATS:
		var row: Dictionary = _rows[stat]
		var bar: ProgressBar = row["bar"]
		var level_label: Label = row["level"]
		var upgrade_button: Button = row["button"]

		bar.value = Garage.stat_value(car, stat)
		var current := Garage.level(car, stat)
		level_label.text = tr("LVL %d/%d") % [current, Garage.MAX_LEVEL]
		var cost := Garage.upgrade_cost(car, stat)
		if cost <= 0:
			upgrade_button.text = tr("MAX")
			upgrade_button.disabled = true
		else:
			upgrade_button.text = Garage.format_credits(cost)
			upgrade_button.disabled = false


func _on_upgrade_pressed(stat: String) -> void:
	var car := RaceConfig.player_car
	var cost := Garage.upgrade_cost(car, stat)
	if cost <= 0:
		message_label.text = tr("%s è già al livello massimo.") % tr(Garage.STAT_NAMES[stat])
		return
	if Garage.credits < cost:
		message_label.text = (
			tr("Crediti insufficienti: servono %s.") % Garage.format_credits(cost)
		)
		return
	Garage.buy_upgrade(car, stat)
	message_label.text = (
		tr("%s portata a LVL %d.") % [tr(Garage.STAT_NAMES[stat]), Garage.level(car, stat)]
	)
	_refresh()


func _on_start_button_pressed() -> void:
	Series.clear_active()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_series_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/SeriesMenu.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/CarSelect.tscn")
