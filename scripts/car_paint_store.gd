extends Node

const PAINT_SHADER := preload("res://shaders/car_paint_custom.gdshader")
const FILE_NAME := "paint.cfg"

const FINISH_STOCK := "originale"
const FINISH_NORMAL := "normale"
const FINISH_MATTE := "opaco"
const FINISH_METALLIC := "metallizzato"
const FINISH_CHROMATIC := "cromatico"
const FINISHES: Array[String] = [
	FINISH_NORMAL, FINISH_MATTE, FINISH_METALLIC, FINISH_CHROMATIC
]
const FINISH_LABELS := {
	FINISH_STOCK: "Originale",
	FINISH_NORMAL: "Normale",
	FINISH_MATTE: "Opaco",
	FINISH_METALLIC: "Metallizzato",
	FINISH_CHROMATIC: "Cromatico",
}
const FINISH_INDEX := {
	FINISH_NORMAL: 0,
	FINISH_MATTE: 1,
	FINISH_METALLIC: 2,
	FINISH_CHROMATIC: 3,
}

const DEFAULT_PRIMARY := Color(0.86, 0.1, 0.12)
const DEFAULT_SECONDARY := Color(0.95, 0.95, 0.95)
const SPLIT_HEIGHT := 0.52
const SPLIT_SOFTNESS := 0.035
const UNLOCK_COST := 20

# 48 preset colors: no hex fields and no free color picker in the UI.
const PALETTE: Array[Dictionary] = [
	{"name": "Bianco", "color": Color(0.95, 0.95, 0.95)},
	{"name": "Avorio", "color": Color(0.93, 0.89, 0.78)},
	{"name": "Grigio chiaro", "color": Color(0.72, 0.74, 0.77)},
	{"name": "Argento", "color": Color(0.62, 0.65, 0.7)},
	{"name": "Grigio", "color": Color(0.47, 0.5, 0.54)},
	{"name": "Grafite", "color": Color(0.3, 0.32, 0.36)},
	{"name": "Antracite", "color": Color(0.18, 0.19, 0.22)},
	{"name": "Nero", "color": Color(0.05, 0.05, 0.06)},
	{"name": "Rosso", "color": Color(0.86, 0.1, 0.12)},
	{"name": "Rosso scuro", "color": Color(0.55, 0.06, 0.09)},
	{"name": "Bordeaux", "color": Color(0.45, 0.08, 0.18)},
	{"name": "Corallo", "color": Color(0.95, 0.36, 0.32)},
	{"name": "Arancio", "color": Color(0.95, 0.45, 0.08)},
	{"name": "Ambra", "color": Color(0.95, 0.62, 0.1)},
	{"name": "Oro", "color": Color(0.85, 0.68, 0.25)},
	{"name": "Rame", "color": Color(0.72, 0.4, 0.24)},
	{"name": "Giallo", "color": Color(0.96, 0.83, 0.15)},
	{"name": "Limone", "color": Color(0.85, 0.9, 0.25)},
	{"name": "Verde lime", "color": Color(0.55, 0.85, 0.2)},
	{"name": "Verde", "color": Color(0.16, 0.62, 0.3)},
	{"name": "Verde bosco", "color": Color(0.1, 0.4, 0.22)},
	{"name": "Verde acqua", "color": Color(0.25, 0.75, 0.62)},
	{"name": "Menta", "color": Color(0.62, 0.9, 0.78)},
	{"name": "Oliva", "color": Color(0.45, 0.48, 0.25)},
	{"name": "Azzurro", "color": Color(0.5, 0.78, 0.95)},
	{"name": "Celeste", "color": Color(0.28, 0.6, 0.9)},
	{"name": "Blu", "color": Color(0.12, 0.35, 0.85)},
	{"name": "Blu reale", "color": Color(0.08, 0.2, 0.65)},
	{"name": "Blu navy", "color": Color(0.06, 0.12, 0.3)},
	{"name": "Blu notte", "color": Color(0.03, 0.07, 0.18)},
	{"name": "Turchese", "color": Color(0.1, 0.65, 0.72)},
	{"name": "Petrolio", "color": Color(0.1, 0.32, 0.38)},
	{"name": "Lilla", "color": Color(0.7, 0.6, 0.9)},
	{"name": "Viola", "color": Color(0.48, 0.25, 0.75)},
	{"name": "Porpora", "color": Color(0.35, 0.1, 0.4)},
	{"name": "Magenta", "color": Color(0.85, 0.12, 0.6)},
	{"name": "Fucsia", "color": Color(0.95, 0.2, 0.65)},
	{"name": "Rosa", "color": Color(0.95, 0.55, 0.7)},
	{"name": "Rosa cipria", "color": Color(0.96, 0.76, 0.78)},
	{"name": "Pesca", "color": Color(0.97, 0.66, 0.5)},
	{"name": "Bianco perla", "color": Color(0.93, 0.94, 0.9)},
	{"name": "Champagne", "color": Color(0.88, 0.78, 0.58)},
	{"name": "Bronzo", "color": Color(0.6, 0.42, 0.2)},
	{"name": "Militare", "color": Color(0.32, 0.36, 0.24)},
	{"name": "Blu ghiaccio", "color": Color(0.62, 0.8, 0.88)},
	{"name": "Grigio fumo", "color": Color(0.4, 0.42, 0.45)},
	{"name": "Testa di moro", "color": Color(0.24, 0.14, 0.1)},
	{"name": "Verde smeraldo", "color": Color(0.06, 0.55, 0.38)},
]

# Body surfaces per car. Quaternius cars expose named materials, while the
# Grab3D cars use one textured body mesh plus optional flat "_paint" panels.
# Hue/thresholds were tuned on each body atlas to recolor only the paint.
const BODY_RULES := {
	"coupe": {"materials": ["White"]},
	"sports": {"materials": ["Orange", "DarkOrange"]},
	"sedan": {"materials": ["Blue"]},
	"city": {"materials": ["LightBlue"]},
	"police": {"materials": ["White"]},
	"taxi": {"materials": ["Yellow"]},
	"suv": {"materials": ["White"]},
	"sedan_50": {
		"textured": true, "hue": 0.455, "tolerance": 0.055,
		"saturation": 0.15, "value": 0.28, "reference": 0.765,
	},
	"wagon_50": {
		"textured": true, "hue": 0.585, "tolerance": 0.05,
		"saturation": 0.20, "value": 0.30, "reference": 0.871,
	},
	"pickup_50": {
		"textured": true, "hue": 0.265, "tolerance": 0.07,
		"saturation": 0.10, "value": 0.30, "reference": 0.702,
	},
	"roadster_50": {
		"textured": true, "hue": 0.975, "tolerance": 0.05,
		"saturation": 0.25, "value": 0.25, "reference": 0.792,
	},
	"convertible_60": {
		"textured": true, "hue": 0.585, "tolerance": 0.045,
		"saturation": 0.25, "value": 0.30, "reference": 0.922,
	},
	"compact_60": {
		"textured": true, "hue": 0.029, "tolerance": 0.045,
		"saturation": 0.25, "value": 0.30, "reference": 0.871,
	},
	"microbus_60": {
		"textured": true, "hue": 0.486, "tolerance": 0.05,
		"saturation": 0.25, "value": 0.25, "reference": 0.596,
	},
	"sports_60": {
		"textured": true, "hue": 0.115, "tolerance": 0.032,
		"saturation": 0.38, "value": 0.35, "reference": 0.835,
	},
	"coupe_70": {
		"textured": true, "hue": 0.484, "tolerance": 0.05,
		"saturation": 0.18, "value": 0.25, "reference": 0.592,
	},
	"hatchback_70": {
		"textured": true, "hue": 0.982, "tolerance": 0.045,
		"saturation": 0.25, "value": 0.25, "reference": 0.792,
	},
	"pickup_70": {
		"textured": true, "hue": 0.035, "tolerance": 0.035,
		"saturation": 0.30, "value": 0.30, "reference": 0.871,
	},
	"sedan_70": {
		"textured": true, "hue": 0.262, "tolerance": 0.06,
		"saturation": 0.10, "value": 0.30, "reference": 0.694,
	},
	"hatchback_80": {
		"textured": true, "hue": 0.716, "tolerance": 0.05,
		"saturation": 0.20, "value": 0.30, "reference": 0.863,
	},
	"sedan_80": {
		"textured": true, "hue": 0.583, "tolerance": 0.045,
		"saturation": 0.20, "value": 0.30, "reference": 0.871,
	},
	"sports_80": {
		"textured": true, "hue": 0.981, "tolerance": 0.05,
		"saturation": 0.25, "value": 0.25, "reference": 0.792,
	},
	"wagon_80": {
		"textured": true, "hue": 0.5, "tolerance": 0.8,
		"saturation": -0.02, "max_saturation": 0.3, "value": 0.5, "reference": 0.88,
	},
	"van_80": {
		"textured": true, "hue": 0.452, "tolerance": 0.05,
		"saturation": 0.26, "value": 0.62, "reference": 0.83,
	},
	"compact_90": {
		"textured": true, "hue": 0.716, "tolerance": 0.05,
		"saturation": 0.26, "value": 0.70, "reference": 0.91,
	},
	"van_90": {
		"textured": true, "hue": 0.716, "tolerance": 0.05,
		"saturation": 0.26, "value": 0.70, "reference": 0.925,
	},
	"hatchback_90": {
		"textured": true, "hue": 0.029, "tolerance": 0.045,
		"saturation": 0.36, "value": 0.70, "reference": 0.91,
	},
	"minivan_90": {
		"textured": true, "hue": 0.452, "tolerance": 0.05,
		"saturation": 0.26, "value": 0.62, "reference": 0.81,
	},
	"offroad_90": {
		"textured": true, "hue": 0.119, "tolerance": 0.04,
		"saturation": 0.48, "value": 0.72, "reference": 0.85,
	},
	"pickup_90": {
		"textured": true, "hue": 0.584, "tolerance": 0.045,
		"saturation": 0.27, "value": 0.72, "reference": 0.918,
	},
	"police_90": {
		"textured": true, "hue": 0.5, "tolerance": 0.8,
		"saturation": -0.02, "max_saturation": 0.3, "value": 0.5, "reference": 0.92,
	},
	"sedan_90": {
		"textured": true, "hue": 0.486, "tolerance": 0.05,
		"saturation": 0.33, "value": 0.48, "reference": 0.643,
	},
	"sports_90": {
		"textured": true, "hue": 0.485, "tolerance": 0.05,
		"saturation": 0.33, "value": 0.48, "reference": 0.647,
	},
	"wagon_90": {
		"textured": true, "hue": 0.5, "tolerance": 0.8,
		"saturation": -0.02, "max_saturation": 0.3, "value": 0.6, "reference": 0.925,
	},
	"suv_90": {
		"textured": true, "hue": 0.274, "tolerance": 0.05,
		"saturation": 0.12, "value": 0.56, "reference": 0.745,
	},
	"taxi_90": {
		"textured": true, "hue": 0.119, "tolerance": 0.04,
		"saturation": 0.48, "value": 0.72, "reference": 0.89,
	},
	"atomic": {
		"textured": true, "hue": 0.716, "tolerance": 0.05,
		"saturation": 0.26, "value": 0.72, "reference": 0.922,
	},
	"compact": {
		"textured": true, "hue": 0.446, "tolerance": 0.05,
		"saturation": 0.19, "value": 0.62, "reference": 0.776,
	},
	"convertible": {
		"textured": true, "hue": 0.039, "tolerance": 0.045,
		"saturation": 0.37, "value": 0.50, "reference": 0.871,
	},
	"coupe_modern": {
		"textured": true, "hue": 0.729, "tolerance": 0.05,
		"saturation": 0.20, "value": 0.70, "reference": 0.882,
	},
	"buggy": {
		"textured": true, "hue": 0.061, "tolerance": 0.045,
		"saturation": 0.34, "value": 0.75, "reference": 0.961,
	},
	"electric": {
		"textured": true, "hue": 0.580, "tolerance": 0.045,
		"saturation": 0.27, "value": 0.72, "reference": 0.902,
	},
	"lowrider": {
		"textured": true, "hue": 0.729, "tolerance": 0.05,
		"saturation": 0.20, "value": 0.70, "reference": 0.894,
	},
	"microcar": {
		"textured": true, "hue": 0.440, "tolerance": 0.05,
		"saturation": 0.19, "value": 0.62, "reference": 0.851,
	},
	"minivan": {
		"textured": true, "hue": 0.729, "tolerance": 0.05,
		"saturation": 0.20, "value": 0.70, "reference": 0.882,
	},
	"muscle": {
		"textured": true, "hue": 0.120, "tolerance": 0.04,
		"saturation": 0.38, "value": 0.75, "reference": 0.945,
	},
	"rally": {
		"textured": true, "hue": 0.581, "tolerance": 0.045,
		"saturation": 0.27, "value": 0.72, "reference": 0.875,
	},
	"wagon": {
		"textured": true, "hue": 0.444, "tolerance": 0.05,
		"saturation": 0.19, "value": 0.62, "reference": 0.824,
	},
	"tuk_tuk": {
		"textured": true, "hue": 0.118, "tolerance": 0.04,
		"saturation": 0.45, "value": 0.72, "reference": 0.851,
	},
	"classic": {
		"textured": true, "hue": 0.940, "tolerance": 0.045,
		"saturation": 0.24, "value": 0.72, "reference": 0.953,
	},
	"hatchback": {
		"textured": true, "hue": 0.432, "tolerance": 0.05,
		"saturation": 0.23, "value": 0.62, "reference": 0.824,
	},
	"limo": {
		"textured": true, "hue": 0.939, "tolerance": 0.045,
		"saturation": 0.24, "value": 0.72, "reference": 0.945,
	},
	"hover": {
		"textured": true, "hue": 0.5, "tolerance": 0.8,
		"saturation": -0.02, "max_saturation": 0.32, "value": 0.5, "reference": 0.93,
	},
	"police_modern": {
		"textured": true, "hue": 0.650, "tolerance": 0.05,
		"saturation": 0.15, "value": 0.15, "reference": 0.286,
	},
	"race_car": {
		"textured": true, "hue": 0.058, "tolerance": 0.045,
		"saturation": 0.22, "value": 0.62, "reference": 0.88,
	},
	"sedan_modern": {
		"textured": true, "hue": 0.576, "tolerance": 0.045,
		"saturation": 0.30, "value": 0.68, "reference": 0.90,
	},
	"sports_modern": {
		"textured": true, "hue": 0.021, "tolerance": 0.042,
		"saturation": 0.35, "value": 0.70, "reference": 0.92,
	},
	"suv_modern": {
		"textured": true, "hue": 0.576, "tolerance": 0.045,
		"saturation": 0.30, "value": 0.66, "reference": 0.89,
	},
	"taxi_modern": {
		"textured": true, "hue": 0.118, "tolerance": 0.038,
		"saturation": 0.40, "value": 0.72, "reference": 0.95,
	},
}

var _states := {}
var _unlocks := {}
var _path: String


func _ready() -> void:
	_path = _paint_path()
	_load()


func _paint_path() -> String:
	var base_dir := OS.get_executable_path().get_base_dir()
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	return base_dir.path_join(FILE_NAME)


func _default_state() -> Dictionary:
	return {
		"finish": FINISH_STOCK,
		"primary": DEFAULT_PRIMARY,
		"secondary": DEFAULT_SECONDARY,
		"two_tone": false,
	}


func _state(car_id: String) -> Dictionary:
	if not _states.has(car_id):
		_states[car_id] = _default_state()
	return _states[car_id]


func paint_for(car_id: String) -> Dictionary:
	return _state(car_id).duplicate()


func unlocked(car_id: String) -> bool:
	return _unlocks.has(car_id)


func unlock(car_id: String) -> void:
	if not BODY_RULES.has(car_id):
		return
	_unlocks[car_id] = true
	save()


func is_stock(car_id: String) -> bool:
	return String(_state(car_id)["finish"]) == FINISH_STOCK


func primary_color(car_id: String) -> Color:
	return _state(car_id)["primary"]


func secondary_color(car_id: String) -> Color:
	return _state(car_id)["secondary"]


func two_tone(car_id: String) -> bool:
	return bool(_state(car_id)["two_tone"])


func finish(car_id: String) -> String:
	return String(_state(car_id)["finish"])


func set_finish(car_id: String, value: String) -> void:
	if not unlocked(car_id):
		return
	if value != FINISH_STOCK and not FINISHES.has(value):
		return
	var state := _state(car_id)
	state["finish"] = value
	if value == FINISH_STOCK:
		state["two_tone"] = false
	save()


func set_primary_color(car_id: String, color: Color) -> void:
	if not unlocked(car_id):
		return
	var state := _state(car_id)
	state["primary"] = color
	if String(state["finish"]) == FINISH_STOCK:
		state["finish"] = FINISH_NORMAL
	save()


func set_secondary_color(car_id: String, color: Color) -> void:
	if not unlocked(car_id):
		return
	var state := _state(car_id)
	state["secondary"] = color
	if String(state["finish"]) == FINISH_STOCK:
		state["finish"] = FINISH_NORMAL
	save()


func set_two_tone(car_id: String, enabled: bool) -> void:
	if not unlocked(car_id):
		return
	var state := _state(car_id)
	state["two_tone"] = enabled
	if enabled and String(state["finish"]) == FINISH_STOCK:
		state["finish"] = FINISH_NORMAL
	save()


func reset_car(car_id: String) -> void:
	_states[car_id] = _default_state()
	save()


func reset_all() -> void:
	_states.clear()
	_unlocks.clear()
	save()


func _load() -> void:
	_states.clear()
	_unlocks.clear()
	var config := ConfigFile.new()
	if config.load(_path) != OK:
		return
	for car_id in BODY_RULES:
		if not config.has_section(car_id):
			continue
		var state := _default_state()
		var loaded_finish := String(config.get_value(car_id, "finish", FINISH_STOCK))
		if loaded_finish != FINISH_STOCK and FINISHES.has(loaded_finish):
			state["finish"] = loaded_finish
		var p = config.get_value(car_id, "primary", DEFAULT_PRIMARY)
		if typeof(p) == TYPE_COLOR:
			state["primary"] = p
		var s = config.get_value(car_id, "secondary", DEFAULT_SECONDARY)
		if typeof(s) == TYPE_COLOR:
			state["secondary"] = s
		state["two_tone"] = bool(config.get_value(car_id, "two_tone", false))
		if String(state["finish"]) == FINISH_STOCK:
			state["two_tone"] = false
		_states[car_id] = state
		if config.has_section("unlocks") and bool(config.get_value("unlocks", car_id, false)):
			_unlocks[car_id] = true
		# I colori gia' salvati prima dell'acquisto restano disponibili.
		if String(state["finish"]) != FINISH_STOCK:
			_unlocks[car_id] = true


func save() -> void:
	var config := ConfigFile.new()
	for car_id in _unlocks:
		config.set_value("unlocks", car_id, true)
	for car_id in _states:
		var state: Dictionary = _states[car_id]
		if String(state["finish"]) == FINISH_STOCK:
			continue
		config.set_value("unlocks", car_id, true)
		config.set_value(car_id, "finish", state["finish"])
		config.set_value(car_id, "primary", state["primary"])
		config.set_value(car_id, "secondary", state["secondary"])
		config.set_value(car_id, "two_tone", state["two_tone"])
	var error := config.save(_path)
	if error != OK:
		push_warning("Could not save paint to %s (error %d)" % [_path, error])


func apply(car_root: Node3D, car_id: String) -> void:
	var rule: Dictionary = BODY_RULES.get(car_id, {})
	if rule.is_empty():
		return
	var state := paint_for(car_id)
	var stock := String(state["finish"]) == FINISH_STOCK or not unlocked(car_id)
	_apply_node(car_root, rule, state, stock)


func _apply_node(node: Node, rule: Dictionary, state: Dictionary, stock: bool) -> void:
	if node is MeshInstance3D:
		_apply_mesh(node as MeshInstance3D, rule, state, stock)
	for child in node.get_children():
		_apply_node(child, rule, state, stock)


func _apply_mesh(mesh: MeshInstance3D, rule: Dictionary, state: Dictionary, stock: bool) -> void:
	if mesh.mesh == null:
		return
	var textured_rule := bool(rule.get("textured", false))
	var surface_count := mesh.mesh.get_surface_count()
	for i in surface_count:
		var material := mesh.mesh.surface_get_material(i)
		var std := material as StandardMaterial3D
		var surface_name := String(mesh.mesh.surface_get_name(i))
		var material_name := String(material.resource_name) if material != null else ""
		var is_body := false
		var textured := false

		if textured_rule and String(mesh.name).ends_with("_body"):
			is_body = true
			textured = true
		elif textured_rule and material_name.contains("_paint"):
			is_body = true
		elif rule.has("materials"):
			var names: Array = rule["materials"]
			is_body = names.has(surface_name) or names.has(material_name)

		if not is_body:
			continue
		if stock:
			mesh.set_surface_override_material(i, null)
			continue
		mesh.set_surface_override_material(
			i, _build_material(mesh, std, rule, state, textured)
		)


func _build_material(
	mesh: MeshInstance3D,
	source: StandardMaterial3D,
	rule: Dictionary,
	state: Dictionary,
	textured: bool
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = PAINT_SHADER

	var bounds := mesh.get_aabb()
	material.set_shader_parameter("height_min", bounds.position.y)
	material.set_shader_parameter("height_max", bounds.end.y)
	material.set_shader_parameter("split_height", SPLIT_HEIGHT)
	material.set_shader_parameter("split_softness", SPLIT_SOFTNESS)
	material.set_shader_parameter("two_tone", bool(state["two_tone"]))
	material.set_shader_parameter("primary_color", state["primary"])
	material.set_shader_parameter("secondary_color", state["secondary"])
	material.set_shader_parameter("finish", int(FINISH_INDEX.get(state["finish"], 0)))

	if textured and source != null and source.albedo_texture != null:
		material.set_shader_parameter("use_texture", true)
		material.set_shader_parameter("albedo_texture", source.albedo_texture)
		var orm: Texture2D = source.roughness_texture
		if orm == null:
			orm = source.metallic_texture
		if orm != null:
			material.set_shader_parameter("orm_texture", orm)
		material.set_shader_parameter("source_hue", float(rule.get("hue", 0.5)))
		material.set_shader_parameter("hue_tolerance", float(rule.get("tolerance", 0.05)))
		material.set_shader_parameter("min_saturation", float(rule.get("saturation", 0.25)))
		material.set_shader_parameter("max_saturation", float(rule.get("max_saturation", 1.0)))
		material.set_shader_parameter("min_value", float(rule.get("value", 0.25)))
		material.set_shader_parameter("body_reference", float(rule.get("reference", 0.8)))
	else:
		material.set_shader_parameter("use_texture", false)

	return material
