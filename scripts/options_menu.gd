extends Control

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(960, 540),
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]

const GENRES: Array[String] = ["phonk", "rock_metal", "american_rap", "synthwave", "techno", "lofi"]
const GENRE_LABELS: Array[String] = ["Phonk", "Rock/Metal", "American Rap", "Synthwave", "Techno", "Lo-Fi"]

const FPS_VALUES: Array[int] = [30, 60, 0]
const FPS_LABELS: Array[String] = ["30", "60", "Illimitati"]

@onready var resolution_option: OptionButton = %ResolutionOption
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var fps_option: OptionButton = %FpsOption
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var genre_option: OptionButton = %GenreOption
@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var ai_option: OptionButton = %AiOption
@onready var language_option: OptionButton = %LanguageOption
@onready var reset_button: Button = %ResetButton
@onready var reset_status: Label = %ResetStatus
@onready var reset_dialog: ConfirmationDialog = %ResetDialog


func _ready() -> void:
	for res in RESOLUTIONS:
		resolution_option.add_item("%d x %d" % [res.x, res.y])
	for i in GENRES.size():
		genre_option.add_item(GENRE_LABELS[i])
	for i in FPS_VALUES.size():
		fps_option.add_item(FPS_LABELS[i])
	for i in Settings.AI_DIFFICULTY_LABELS.size():
		ai_option.add_item(Settings.AI_DIFFICULTY_LABELS[i])
	for language in Loc.languages():
		language_option.add_item(str(language["label"]))

	resolution_option.select(_current_resolution_index())
	genre_option.select(GENRES.find(AudioManager.current_genre))
	fps_option.select(_current_fps_index())
	ai_option.select(Settings.AI_DIFFICULTIES.find(Settings.ai_difficulty))
	language_option.select(Loc.index_of(Loc.current))
	_refresh_dialog_language()

	music_slider.set_value_no_signal(roundi(AudioManager.music_volume * 100.0))
	sfx_slider.set_value_no_signal(roundi(AudioManager.sfx_volume * 100.0))
	_update_volume_label(music_value, music_slider.value)
	_update_volume_label(sfx_value, sfx_slider.value)
	AudioManager.connect_button_sfx(self)

	var is_fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_check.set_pressed_no_signal(is_fullscreen)
	resolution_option.disabled = is_fullscreen

	if is_fullscreen:
		fullscreen_check.grab_focus()
	else:
		resolution_option.grab_focus()


func _on_resolution_option_item_selected(index: int) -> void:
	var resolution := RESOLUTIONS[index]
	DisplayServer.window_set_size(resolution)
	_center_window(resolution)
	Settings.save()


func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	resolution_option.disabled = toggled_on
	Settings.save()


func _on_fps_option_item_selected(index: int) -> void:
	Settings.apply_max_fps(FPS_VALUES[index])
	Settings.save()


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value / 100.0)
	_update_volume_label(music_value, value)
	Settings.save()


func _on_genre_option_item_selected(index: int) -> void:
	AudioManager.set_genre(GENRES[index])
	Settings.save()


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value / 100.0)
	_update_volume_label(sfx_value, value)
	Settings.save()


func _update_volume_label(label: Label, value: float) -> void:
	label.text = "%d%%" % roundi(value)


func _on_ai_option_item_selected(index: int) -> void:
	Settings.ai_difficulty = Settings.AI_DIFFICULTIES[index]
	Settings.save()


func _on_language_option_item_selected(index: int) -> void:
	var list := Loc.languages()
	if index < 0 or index >= list.size():
		return
	Loc.set_language(str(list[index]["code"]))
	_refresh_dialog_language()
	reset_status.text = ""


func _refresh_dialog_language() -> void:
	reset_dialog.title = tr("Azzera progressi")
	reset_dialog.dialog_text = tr(
		"Vuoi davvero azzerare tutti i progressi?\n\nCrediti, upgrade delle auto e serie di gare torneranno allo stato iniziale."
	)
	reset_dialog.ok_button_text = tr("Azzera")
	reset_dialog.cancel_button_text = tr("Annulla")


func _on_reset_button_pressed() -> void:
	reset_status.text = ""
	reset_dialog.popup_centered()


func _on_reset_confirmed() -> void:
	Garage.reset_progress()
	Series.reset_progress()
	DailyReward.reset()
	CarPaint.reset_all()
	reset_status.text = tr("Progressi azzerati. %s · %s") % [
		Garage.format_credits(Garage.credits), Garage.format_gold(Garage.gold)
	]


func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ControlsMenu.tscn")


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/CreditsMenu.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _current_resolution_index() -> int:
	var window_size := get_window().size
	var index := RESOLUTIONS.find(window_size)
	return index if index != -1 else 0


func _current_fps_index() -> int:
	var index := FPS_VALUES.find(Engine.max_fps)
	return index if index != -1 else FPS_VALUES.find(60)


func _center_window(resolution: Vector2i) -> void:
	var screen := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	get_window().position = screen.position + (screen.size - resolution) / 2
