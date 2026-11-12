extends Node

const ENGINE_DATA := preload("res://scripts/engine_data.gd")
const SHIFT_STREAM: AudioStream = preload("res://audio/gear_shift.wav")
const ENGINE_DIR := "res://audio/engines/"
const FALLBACK_CAR := "coupe"

const IDLE_PITCH := 0.62
const MAX_PITCH := 2.05
const IDLE_DB := -18.0
const MAX_DB := -8.0

var _idle_pitch := IDLE_PITCH
var _max_pitch := MAX_PITCH
var _idle_db := IDLE_DB
var _max_db := MAX_DB
var _shift_pitch := 1.0
var _car_id := ""

var _target_pitch := IDLE_PITCH
var _target_db := IDLE_DB
var _pitch := IDLE_PITCH
var _db := IDLE_DB

@onready var _engine: AudioStreamPlayer = $Engine
@onready var _shift: AudioStreamPlayer = $Shift


func _ready() -> void:
	_shift.stream = SHIFT_STREAM
	configure(FALLBACK_CAR)


func configure(car_id: String) -> void:
	var entry: Dictionary = ENGINE_DATA.CAR_ENGINE.get(
		car_id, ENGINE_DATA.CAR_ENGINE[FALLBACK_CAR]
	)
	var profile: Dictionary = ENGINE_DATA.ENGINES[entry["family"]]
	var stream := _load_stream(car_id)
	if stream == null:
		return

	_car_id = car_id
	_idle_pitch = float(profile["idle"]) * float(entry["pitch"])
	_max_pitch = float(profile["max"]) * float(entry["pitch"])
	_idle_db = float(profile["idle_db"]) + float(entry["db"])
	_max_db = float(profile["max_db"]) + float(entry["db"])
	_shift_pitch = float(profile["shift"])
	_target_pitch = _idle_pitch
	_target_db = _idle_db
	_pitch = _idle_pitch
	_db = _idle_db

	_engine.stream = stream
	_engine.pitch_scale = _idle_pitch
	_engine.volume_db = _idle_db + AudioManager.sfx_db_offset()
	_shift.volume_db = AudioManager.sfx_db_offset()
	if _engine.playing:
		_engine.stop()
	_engine.play()


func _load_stream(car_id: String) -> AudioStreamWAV:
	var path := ENGINE_DIR + car_id + ".wav"
	if not ResourceLoader.exists(path):
		path = ENGINE_DIR + FALLBACK_CAR + ".wav"
	var stream := load(path) as AudioStreamWAV
	if stream != null and stream.loop_mode != AudioStreamWAV.LOOP_FORWARD:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	return stream


func update_engine(revs: float, throttle: float) -> void:
	revs = clampf(revs, 0.0, 1.0)
	_target_pitch = lerpf(_idle_pitch, _max_pitch, revs)
	var load := clampf(revs * 0.7 + throttle * 0.45, 0.0, 1.0)
	_target_db = lerpf(_idle_db, _max_db, load)


func play_shift() -> void:
	if not AudioManager.sfx_enabled:
		return
	_shift.pitch_scale = _shift_pitch * randf_range(0.94, 1.06)
	_shift.volume_db = AudioManager.sfx_db_offset()
	_shift.play()


func _process(delta: float) -> void:
	_pitch = move_toward(_pitch, _target_pitch, delta * 4.0)
	_db = move_toward(_db, _target_db, delta * 18.0)
	_engine.pitch_scale = _pitch
	_engine.volume_db = _db + AudioManager.sfx_db_offset()
