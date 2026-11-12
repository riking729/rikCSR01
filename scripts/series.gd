extends Node

const FILE_NAME := "series.cfg"

const SERIES := [
	{
		"id": "cittadina",
		"name": "Serie Cittadina",
		"prizes": [1500, 2500, 4000],
		"ai_base": 0.0,
		"ai_step": 0.005,
	},
	{
		"id": "nazionale",
		"name": "Serie Nazionale",
		"prizes": [3000, 5000, 7000, 10000],
		"ai_base": 0.02,
		"ai_step": 0.0075,
	},
	{
		"id": "campioni",
		"name": "Serie Campioni",
		"prizes": [6000, 9000, 13000, 18000, 25000],
		"ai_base": 0.04,
		"ai_step": 0.01,
	},
	{
		"id": "gran_turismo",
		"name": "Torneo Gran Turismo",
		"prizes": [9000, 13000, 18000, 24000, 31000, 40000],
		"ai_base": 0.06,
		"ai_step": 0.01,
	},
	{
		"id": "leggende",
		"name": "Serie Leggende",
		"prizes": [15000, 20000, 26000, 33000, 41000, 50000, 62000],
		"ai_base": 0.08,
		"ai_step": 0.012,
	},
]

const BASE_GOLD := 5

var selected_id := "cittadina"
var active_id := ""
var active_race := 0

var _progress := {}
var _path: String


func _ready() -> void:
	_path = _series_path()
	_load()


func _series_path() -> String:
	var base_dir := OS.get_executable_path().get_base_dir()
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	return base_dir.path_join(FILE_NAME)


func _load() -> void:
	_progress = {}
	for entry in SERIES:
		_progress[entry["id"]] = 0

	var config := ConfigFile.new()
	if config.load(_path) != OK:
		return

	for entry in SERIES:
		var id: String = entry["id"]
		_progress[id] = clampi(int(config.get_value(id, "won", 0)), 0, race_count(id))


func reset_progress() -> void:
	for entry in SERIES:
		_progress[entry["id"]] = 0
	selected_id = "cittadina"
	clear_active()
	save()


func save() -> void:
	var config := ConfigFile.new()
	for entry in SERIES:
		var id: String = entry["id"]
		config.set_value(id, "won", progress(id))
	var error := config.save(_path)
	if error != OK:
		push_warning("Could not save series to %s (error %d)" % [_path, error])


func find(id: String) -> Dictionary:
	for entry in SERIES:
		if entry["id"] == id:
			return entry
	return {}


func race_count(id: String) -> int:
	var prizes: Array = find(id)["prizes"]
	return prizes.size()


func prize(id: String, index: int) -> int:
	var prizes: Array = find(id)["prizes"]
	return int(prizes[clampi(index, 0, prizes.size() - 1)])


func gold_prize(id: String, index: int) -> int:
	var first := prize(id, 0)
	if first <= 0:
		return BASE_GOLD
	var scaled := int(round(float(BASE_GOLD) * float(prize(id, index)) / float(first)))
	return maxi(BASE_GOLD, scaled)


func difficulty(id: String, index: int) -> float:
	var entry := find(id)
	if entry.is_empty():
		return 0.0
	return float(entry["ai_base"]) + float(entry["ai_step"]) * clampi(index, 0, race_count(id) - 1)


func active_difficulty() -> float:
	if not is_active():
		return 0.0
	return difficulty(active_id, active_race)


func progress(id: String) -> int:
	return int(_progress[id])


func is_completed(id: String) -> bool:
	return progress(id) >= race_count(id)


func begin(id: String) -> void:
	active_id = id
	active_race = progress(id)


func is_active() -> bool:
	return active_id != "" and not find(active_id).is_empty()


func active_name() -> String:
	return str(find(active_id)["name"])


func active_race_count() -> int:
	return race_count(active_id)


func active_prize() -> int:
	return prize(active_id, active_race)


func active_gold_prize() -> int:
	return gold_prize(active_id, active_race)


func has_next() -> bool:
	return is_active() and active_race < race_count(active_id)


func advance() -> void:
	if active_id == "":
		return
	active_race = mini(active_race + 1, race_count(active_id))
	_progress[active_id] = maxi(progress(active_id), active_race)
	save()


func clear_active() -> void:
	active_id = ""
	active_race = 0
