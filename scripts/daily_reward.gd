extends Node

const FILE_NAME := "daily_reward.cfg"
const COOLDOWN_SECONDS := 86400
const MIN_REWARD_STEPS := 5
const MAX_REWARD_STEPS := 20
const REWARD_STEP := 100

var _last_claim_unix := 0
var _pending_anchor := -1
var _pending_amount := 0
var _pending_gold := false
var _auto_shown_anchor := -1
var _path: String


func _ready() -> void:
	_path = _daily_path()
	_load()


func _daily_path() -> String:
	var base_dir := OS.get_executable_path().get_base_dir()
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	return base_dir.path_join(FILE_NAME)


func _load() -> void:
	_last_claim_unix = 0
	_pending_anchor = -1
	_pending_amount = 0
	_pending_gold = false
	var config := ConfigFile.new()
	if config.load(_path) != OK:
		return
	_last_claim_unix = int(config.get_value("daily", "last_claim_unix", 0))
	_pending_anchor = int(config.get_value("daily", "pending_anchor", -1))
	_pending_amount = int(config.get_value("daily", "pending_amount", 0))
	_pending_gold = bool(config.get_value("daily", "pending_gold", false))


func save() -> void:
	var config := ConfigFile.new()
	config.set_value("daily", "last_claim_unix", _last_claim_unix)
	config.set_value("daily", "pending_anchor", _pending_anchor)
	config.set_value("daily", "pending_amount", _pending_amount)
	config.set_value("daily", "pending_gold", _pending_gold)
	var error := config.save(_path)
	if error != OK:
		push_warning("Could not save daily reward to %s (error %d)" % [_path, error])


func now_unix() -> int:
	return int(Time.get_unix_time_from_system())


func is_available() -> bool:
	if _last_claim_unix <= 0:
		return true
	var elapsed := now_unix() - _last_claim_unix
	return elapsed >= COOLDOWN_SECONDS


func seconds_until_available() -> int:
	if _last_claim_unix <= 0:
		return 0
	var remaining := COOLDOWN_SECONDS - (now_unix() - _last_claim_unix)
	return maxi(remaining, 0)


func pending_reward() -> int:
	if not is_available():
		return 0
	if _pending_anchor != _last_claim_unix or _pending_amount <= 0:
		_pending_anchor = _last_claim_unix
		_pending_gold = randi() % 2 == 0
		var steps := randi_range(MIN_REWARD_STEPS, MAX_REWARD_STEPS)
		_pending_amount = steps if _pending_gold else steps * REWARD_STEP
		save()
	return _pending_amount


func pending_is_gold() -> bool:
	pending_reward()
	return _pending_gold


func claim() -> Dictionary:
	if not is_available():
		return {"amount": 0, "gold": false}
	var amount := pending_reward()
	var is_gold := _pending_gold
	_last_claim_unix = now_unix()
	_pending_anchor = -1
	_pending_amount = 0
	_pending_gold = false
	save()
	if is_gold:
		Garage.add_gold(amount)
	else:
		Garage.add_credits(amount)
	return {"amount": amount, "gold": is_gold}


func should_auto_show() -> bool:
	if not is_available() or _auto_shown_anchor == _last_claim_unix:
		return false
	_auto_shown_anchor = _last_claim_unix
	return true


func reset() -> void:
	_last_claim_unix = 0
	_pending_anchor = -1
	_pending_amount = 0
	_pending_gold = false
	_auto_shown_anchor = -1
	save()
