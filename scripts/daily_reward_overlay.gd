extends Control

const ACCENT := Color(1.0, 0.78, 0.3)

signal closed

@onready var _panel: PanelContainer = %Panel
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _amount: Label = %Amount
@onready var _status: Label = %Status
@onready var _wallet: Label = %Wallet
@onready var _claim_button: Button = %ClaimButton
@onready var _close_button: Button = %CloseButton

var _claimed_amount := 0
var _claimed_gold := false
var _force_claim := false


func _ready() -> void:
	visible = false
	_style()
	_claim_button.pressed.connect(_on_claim_pressed)
	_close_button.pressed.connect(close)
	AudioManager.connect_button_sfx(self)


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		if _force_claim and _claimed_amount <= 0:
			get_viewport().set_input_as_handled()
			return
		close()
		get_viewport().set_input_as_handled()


func open(force_claim: bool = false) -> void:
	_claimed_amount = 0
	_claimed_gold = false
	_force_claim = force_claim
	_refresh()
	visible = true
	if _claim_button.disabled:
		_close_button.grab_focus()
	else:
		_claim_button.grab_focus()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func _on_claim_pressed() -> void:
	var reward := DailyReward.claim()
	var amount := int(reward["amount"])
	if amount > 0:
		_claimed_amount = amount
		_claimed_gold = bool(reward["gold"])
	_refresh()


func _refresh() -> void:
	var available := DailyReward.is_available()
	if _claimed_amount > 0:
		_title.text = tr("RICOMPENSA RITIRATA")
		_subtitle.text = tr("Torna tra 24 ore per un'altra ricompensa.")
		_amount.text = "+" + _format_reward(_claimed_amount, _claimed_gold)
		_amount.visible = true
		_status.text = (
			tr("Il bonus è stato aggiunto ai tuoi CR Gold.")
			if _claimed_gold
			else tr("Il bonus è stato aggiunto ai tuoi crediti.")
		)
	elif available:
		_title.text = tr("RICOMPENSA GIORNALIERA")
		_subtitle.text = tr("Un bonus casuale in CR$ o CR Gold ogni 24 ore dall'ultimo ritiro.")
		_amount.text = "+" + _format_reward(
			DailyReward.pending_reward(), DailyReward.pending_is_gold()
		)
		_amount.visible = true
		if _force_claim:
			_status.text = tr("Ritira il bonus per continuare.")
		else:
			_status.text = tr("Bonus di oggi disponibile.")
	else:
		_title.text = tr("RICOMPENSA GIORNALIERA")
		_subtitle.text = tr("Un bonus casuale in CR$ o CR Gold ogni 24 ore dall'ultimo ritiro.")
		_amount.visible = false
		_status.text = tr("Prossimo bonus tra %s.") % _format_remaining(
			DailyReward.seconds_until_available()
		)

	_claim_button.disabled = not available or _claimed_amount > 0
	_claim_button.text = tr("Ritirato") if _claim_button.disabled else tr("Ritira")
	_close_button.text = tr("Chiudi")
	_close_button.disabled = _force_claim and _claimed_amount <= 0
	_wallet.text = tr("Portafoglio: %s   ·   %s") % [
		Garage.format_credits(Garage.credits), Garage.format_gold(Garage.gold)
	]


func _format_reward(amount: int, is_gold: bool) -> String:
	return Garage.format_gold(amount) if is_gold else Garage.format_credits(amount)


func _format_remaining(total_seconds: int) -> String:
	if total_seconds <= 0:
		return tr("pochi istanti")
	var hours := total_seconds / 3600
	var minutes := (total_seconds % 3600) / 60
	if hours > 0:
		return tr("%dh %dmin") % [hours, minutes]
	return tr("%dmin") % maxi(minutes, 1)


func _style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.06, 0.075, 0.98)
	panel_style.border_color = ACCENT
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(18)
	panel_style.shadow_color = Color(0, 0, 0, 0.55)
	panel_style.shadow_size = 24
	_panel.add_theme_stylebox_override("panel", panel_style)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.14, 0.115, 0.06)
	normal.border_color = ACCENT
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(12)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.21, 0.17, 0.08)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.09, 0.09, 0.1)
	disabled.border_color = Color(0.3, 0.3, 0.33)

	for state in ["normal", "focus"]:
		_claim_button.add_theme_stylebox_override(state, normal)
	for state in ["hover", "pressed", "hover_pressed"]:
		_claim_button.add_theme_stylebox_override(state, hover)
	_claim_button.add_theme_stylebox_override("disabled", disabled)
	_claim_button.add_theme_color_override("font_color", ACCENT)
	_claim_button.add_theme_color_override("font_hover_color", Color(1, 0.9, 0.65))
	_claim_button.add_theme_color_override("font_pressed_color", Color(1, 0.9, 0.65))
	_claim_button.add_theme_color_override("font_focus_color", ACCENT)
	_claim_button.add_theme_color_override("font_disabled_color", Color(0.5, 0.46, 0.4))

	var flat := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		_close_button.add_theme_stylebox_override(state, flat)
	_close_button.add_theme_color_override("font_color", Color(0.72, 0.76, 0.84))
	_close_button.add_theme_color_override("font_hover_color", Color(0.95, 0.95, 0.95))
	_close_button.add_theme_color_override("font_pressed_color", Color(0.95, 0.95, 0.95))
	_close_button.add_theme_color_override("font_disabled_color", Color(0.38, 0.4, 0.46))
