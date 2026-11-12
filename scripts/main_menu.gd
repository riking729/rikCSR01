extends Control

const ACCENT := Color(1.0, 0.78, 0.3)
const REWARD_CHECK_SECONDS := 30.0
const CAR_SELECT_SCENE := "res://scenes/CarSelect.tscn"

@onready var _daily_button: Button = %DailyRewardButton
@onready var _daily_overlay: Control = $DailyRewardOverlay
@onready var _wallet_label: Label = %Wallet

var _menu_locked := false
var _play_pressed := false
var _check_timer: Timer


func _ready() -> void:
	AudioManager.connect_button_sfx(self)
	_daily_button.pressed.connect(_on_daily_reward_button_pressed)
	_daily_overlay.connect("closed", _on_daily_overlay_closed)
	_refresh_daily_button()
	_refresh_wallet()

	_check_timer = Timer.new()
	_check_timer.wait_time = REWARD_CHECK_SECONDS
	_check_timer.autostart = true
	_check_timer.timeout.connect(_check_daily_reward)
	add_child(_check_timer)

	if FirstRun.is_notice_pending():
		_set_menu_locked(true)
		FirstRun.notice_closed.connect(_on_first_run_notice_closed)
	else:
		_start_entry_flow()

	_preload_car_select.call_deferred()


func _preload_car_select() -> void:
	# CarSelect precarica 59 modelli 3D: il caricamento in background
	# evita il blocco al primo clic su Gioca dopo l'avvio.
	ResourceLoader.load_threaded_request(CAR_SELECT_SCENE)


func _start_entry_flow() -> void:
	if DailyReward.should_auto_show():
		_open_daily_reward(true)
	else:
		%PlayButton.grab_focus()


func _on_first_run_notice_closed() -> void:
	_set_menu_locked(false)
	_start_entry_flow()


func _check_daily_reward() -> void:
	if _daily_overlay.visible or _menu_locked:
		return
	if DailyReward.should_auto_show():
		_open_daily_reward(true)


func _open_daily_reward(force_claim: bool) -> void:
	if force_claim:
		_set_menu_locked(true)
	_daily_overlay.call("open", force_claim)


func _on_daily_overlay_closed() -> void:
	_refresh_daily_button()
	_refresh_wallet()
	_set_menu_locked(false)
	%PlayButton.grab_focus()


func _refresh_wallet() -> void:
	_wallet_label.text = "%s   ·   %s" % [
		Garage.format_credits(Garage.credits), Garage.format_gold(Garage.gold)
	]


func _set_menu_locked(locked: bool) -> void:
	_menu_locked = locked
	var buttons: Array[Button] = [%PlayButton, _daily_button, %OptionsButton, %QuitButton]
	for button in buttons:
		button.disabled = locked
		button.modulate = Color(1, 1, 1, 0.55) if locked else Color.WHITE


func _refresh_daily_button() -> void:
	if DailyReward.is_available():
		_daily_button.text = tr("Ricompensa giornaliera •")
		_daily_button.add_theme_color_override("font_color", ACCENT)
	else:
		_daily_button.text = tr("Ricompensa giornaliera")
		_daily_button.remove_theme_color_override("font_color")


func _on_daily_reward_button_pressed() -> void:
	_open_daily_reward(false)


func _on_play_button_pressed() -> void:
	if _play_pressed:
		return
	_play_pressed = true
	Series.clear_active()
	if ResourceLoader.load_threaded_get_status(CAR_SELECT_SCENE) == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(CAR_SELECT_SCENE))
	else:
		get_tree().change_scene_to_file(CAR_SELECT_SCENE)


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
