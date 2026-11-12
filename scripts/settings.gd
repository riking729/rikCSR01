extends Node

const FILE_NAME := "settings.cfg"
const DEFAULT_MAX_FPS := 60
const CONTROL_ACTIONS: Array[String] = ["accelerate", "brake", "shift_gear", "nitro"]

const AI_DIFFICULTIES: Array[String] = ["facile", "normale", "difficile", "esperto"]
const AI_DIFFICULTY_LABELS: Array[String] = ["Facile", "Normale", "Difficile", "Esperto"]
const AI_DIFFICULTY_MULT := {
	"facile": 0.96,
	"normale": 1.0,
	"difficile": 1.08,
	"esperto": 1.16,
}

var ai_difficulty := "normale"
var language := "it"

var _path: String
var _windowed_size: Vector2i


func _ready() -> void:
	_path = _settings_path()
	_windowed_size = get_window().size
	_load()
	get_window().size_changed.connect(_on_window_size_changed)


func _settings_path() -> String:
	var base_dir := OS.get_executable_path().get_base_dir()
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	return base_dir.path_join(FILE_NAME)


func _on_window_size_changed() -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		_windowed_size = get_window().size


func _load() -> void:
	apply_max_fps(DEFAULT_MAX_FPS)
	ai_difficulty = "normale"

	var config := ConfigFile.new()
	if config.load(_path) != OK:
		return

	apply_max_fps(int(config.get_value("video", "max_fps", DEFAULT_MAX_FPS)))

	var difficulty: String = str(config.get_value("game", "ai_difficulty", "normale"))
	if AI_DIFFICULTY_MULT.has(difficulty):
		ai_difficulty = difficulty

	language = str(config.get_value("game", "language", "it"))

	var legacy_music := bool(config.get_value("audio", "music", true))
	var legacy_sfx := bool(config.get_value("audio", "sfx", true))
	AudioManager.set_music_volume(
		float(config.get_value("audio", "music_volume", 1.0 if legacy_music else 0.0))
	)
	AudioManager.set_sfx_volume(
		float(config.get_value("audio", "sfx_volume", 1.0 if legacy_sfx else 0.0))
	)
	AudioManager.set_genre(config.get_value("audio", "genre", "phonk"))

	var width: int = config.get_value("video", "width", _windowed_size.x)
	var height: int = config.get_value("video", "height", _windowed_size.y)
	if width > 0 and height > 0:
		_windowed_size = Vector2i(width, height)
		DisplayServer.window_set_size(_windowed_size)

	if config.get_value("video", "fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	_load_controls(config)


func _load_controls(config: ConfigFile) -> void:
	for action in CONTROL_ACTIONS:
		if not config.has_section_key("controls", action):
			continue
		var raw = config.get_value("controls", action)
		var codes: Array[int] = []
		for value in raw:
			codes.append(int(value))
		set_action_keys(action, codes)


func apply_max_fps(fps: int) -> void:
	Engine.max_fps = fps
	# Senza questo il V-Sync blocca gli FPS alla frequenza dello schermo anche con "Illimitati"
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_DISABLED if fps == 0 else DisplayServer.VSYNC_ENABLED
	)


func ai_multiplier() -> float:
	return float(AI_DIFFICULTY_MULT[ai_difficulty])


func format_ai_rating(multiplier: float) -> String:
	# 1e-6 compensa i mezzi punti non rappresentabili esatti in binario (100,5 -> 101)
	return "%d%%" % roundi(multiplier * 100.0 + 0.000001)


func set_action_keys(action: String, codes: Array[int]) -> void:
	InputMap.action_erase_events(action)
	for code in codes:
		var event := InputEventKey.new()
		event.physical_keycode = code
		InputMap.action_add_event(action, event)


func save() -> void:
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if not fullscreen:
		_windowed_size = DisplayServer.window_get_size()

	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", AudioManager.music_volume)
	config.set_value("audio", "sfx_volume", AudioManager.sfx_volume)
	config.set_value("audio", "genre", AudioManager.current_genre)
	config.set_value("game", "ai_difficulty", ai_difficulty)
	config.set_value("game", "language", language)
	if _windowed_size.x > 0 and _windowed_size.y > 0:
		config.set_value("video", "width", _windowed_size.x)
		config.set_value("video", "height", _windowed_size.y)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "max_fps", Engine.max_fps)
	config.set_value("controls", "accelerate", _current_action_keys("accelerate"))
	config.set_value("controls", "brake", _current_action_keys("brake"))
	config.set_value("controls", "shift_gear", _current_action_keys("shift_gear"))
	config.set_value("controls", "nitro", _current_action_keys("nitro"))
	var error := config.save(_path)
	if error != OK:
		push_warning("Could not save settings to %s (error %d)" % [_path, error])


func _current_action_keys(action: String) -> Array[int]:
	var codes: Array[int] = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			codes.append((event as InputEventKey).physical_keycode)
	return codes
