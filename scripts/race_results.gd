extends Control

signal advance_pressed
signal menu_pressed

const WIN_COLOR := Color(1.0, 0.78, 0.3)
const LOSE_COLOR := Color(1.0, 0.38, 0.32)
const DNF_COLOR := Color(1.0, 0.38, 0.32)

@onready var context_label: Label = %Context
@onready var first_name: Label = %FirstName
@onready var first_time: Label = %FirstTime
@onready var second_name: Label = %SecondName
@onready var second_time: Label = %SecondTime
@onready var outcome: Label = %Outcome
@onready var prize_label: Label = %Prize
@onready var advance_button: Button = %AdvanceButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	visible = false


func show_results(
	player_time: float,
	ai_time: float,
	player_name: String,
	ai_name: String,
	prize: int,
	context: String = "",
	advance_label: String = "Avanti",
	show_menu: bool = false,
	player_won: bool = true,
	gold_prize: int = 0
) -> void:
	var player_dnf := player_time < 0.0
	var ai_dnf := ai_time < 0.0
	if player_won:
		first_name.text = player_name
		first_time.text = _format_time(player_time)
		second_name.text = ai_name
		second_time.text = _format_time(ai_time)
		_style_time(first_time, player_dnf)
		_style_time(second_time, ai_dnf)
	else:
		first_name.text = ai_name
		first_time.text = _format_time(ai_time)
		second_name.text = player_name
		second_time.text = _format_time(player_time)
		_style_time(first_time, ai_dnf)
		_style_time(second_time, player_dnf)

	outcome.text = tr("HAI VINTO") if player_won else tr("HAI PERSO")
	outcome.add_theme_color_override("font_color", WIN_COLOR if player_won else LOSE_COLOR)
	var prize_text := tr("Premio: +%s") % Garage.format_credits(prize)
	if gold_prize > 0:
		prize_text = tr("Premio: +%s   ·   +%s") % [
			Garage.format_credits(prize), Garage.format_gold(gold_prize)
		]
	prize_label.text = prize_text
	context_label.text = context
	context_label.visible = context != ""
	advance_button.text = tr(advance_label)
	menu_button.visible = show_menu
	visible = true
	advance_button.grab_focus()


func _style_time(label: Label, dnf: bool) -> void:
	if dnf:
		label.add_theme_color_override("font_color", DNF_COLOR)


func _format_time(seconds: float) -> String:
	if seconds < 0.0:
		return "DNF"
	var total_ms := roundi(seconds * 1000.0)
	var minutes := floori(total_ms / 60000.0)
	var secs := floori((total_ms % 60000) / 1000.0)
	var millis := total_ms % 1000
	if minutes > 0:
		return "%d:%02d.%03d" % [minutes, secs, millis]
	return "%d.%03d s" % [secs, millis]


func _on_advance_button_pressed() -> void:
	advance_pressed.emit()


func _on_menu_button_pressed() -> void:
	menu_pressed.emit()
