extends Node

const PLAYLISTS := {
	"phonk": [
		preload("res://audio/music/phonk/phonk_execution.ogg"),
		preload("res://audio/music/phonk/metaphonk.ogg"),
		preload("res://audio/music/phonk/unbound.ogg"),
		preload("res://audio/music/phonk/cyberpunk_computer_game.ogg"),
	],
	"rock_metal": [
		preload("res://audio/music/rock_metal/battle_metal.ogg"),
		preload("res://audio/music/rock_metal/hard.ogg"),
		preload("res://audio/music/rock_metal/i_cant_stop.ogg"),
		preload("res://audio/music/rock_metal/metalmania.ogg"),
		preload("res://audio/music/rock_metal/hotrock.ogg"),
	],
	"american_rap": [
		preload("res://audio/music/american_rap/powerful_trap_beat.ogg"),
		preload("res://audio/music/american_rap/pista.ogg"),
		preload("res://audio/music/american_rap/its_a_trap.ogg"),
		preload("res://audio/music/american_rap/champion.ogg"),
	],
	"synthwave": [
		preload("res://audio/music/synthwave/neon_laser_horizon.ogg"),
		preload("res://audio/music/synthwave/miami_nights.ogg"),
		preload("res://audio/music/synthwave/future_gladiator.ogg"),
		preload("res://audio/music/synthwave/laser_groove.ogg"),
	],
	"techno": [
		preload("res://audio/music/techno/cant_stop_my_feet.ogg"),
		preload("res://audio/music/techno/high_technologic_beat.ogg"),
		preload("res://audio/music/techno/fingerless_gloves.ogg"),
		preload("res://audio/music/techno/climax.ogg"),
	],
	"lofi": [
		preload("res://audio/music/lofi/daydreams.ogg"),
		preload("res://audio/music/lofi/sonder.ogg"),
		preload("res://audio/music/lofi/echoes_in_blue.ogg"),
		preload("res://audio/music/lofi/sunset_drive.ogg"),
	],
}

const HOVER_STREAM: AudioStream = preload("res://audio/ui_hover.ogg")

const MUSIC_BASE_DB := -10.0
const HOVER_BASE_DB := -8.0
const MUTE_DB := -80.0

var music_enabled := true
var sfx_enabled := true
var music_volume := 1.0
var sfx_volume := 1.0
var current_genre := "phonk"

var _music: AudioStreamPlayer
var _hover: AudioStreamPlayer
var _queue: Array[int] = []
var _last_stream: AudioStream = null


func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.volume_db = _volume_to_db(music_volume, MUSIC_BASE_DB)
	_music.finished.connect(_play_next_track)
	add_child(_music)

	_hover = AudioStreamPlayer.new()
	_hover.stream = HOVER_STREAM
	_hover.volume_db = _volume_to_db(sfx_volume, HOVER_BASE_DB)
	add_child(_hover)

	_play_next_track()


func set_genre(genre: String) -> void:
	if genre == current_genre or not PLAYLISTS.has(genre):
		return
	current_genre = genre
	_queue.clear()
	_play_next_track()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	music_enabled = music_volume > 0.0
	_apply_music_volume()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	sfx_enabled = sfx_volume > 0.0
	if _hover != null:
		_hover.volume_db = _volume_to_db(sfx_volume, HOVER_BASE_DB)


func sfx_db_offset() -> float:
	return _volume_to_db(sfx_volume, 0.0)


func _apply_music_volume() -> void:
	if _music == null:
		return
	_music.volume_db = _volume_to_db(music_volume, MUSIC_BASE_DB)
	_music.stream_paused = not music_enabled


func _volume_to_db(volume: float, base_db: float) -> float:
	if volume <= 0.0:
		return MUTE_DB
	return base_db + linear_to_db(volume)


func play_hover() -> void:
	if sfx_enabled:
		_hover.play()


func connect_button_sfx(root: Node) -> void:
	for button in root.find_children("*", "BaseButton", true, false):
		if not button.mouse_entered.is_connected(play_hover):
			button.mouse_entered.connect(play_hover)


func _play_next_track() -> void:
	var tracks: Array = PLAYLISTS[current_genre]
	if tracks.is_empty():
		return
	if _queue.is_empty():
		for i in tracks.size():
			_queue.append(i)
		_queue.shuffle()
		if tracks.size() > 1 and _last_stream != null and tracks[_queue[0]] == _last_stream:
			_queue.push_back(_queue.pop_front())
	var stream: AudioStream = tracks[_queue.pop_front()]
	_last_stream = stream
	_music.stream = stream
	_music.play()
	_music.stream_paused = not music_enabled
