extends Node3D

const FINISH_SHADER := preload("res://shaders/finish_line.gdshader")

const HALF_SPAN := 4.65
const PYLON_HEIGHT := 3.9
const BANNER_Y := 3.55
const BANNER_SIZE := Vector2(9.7, 0.78)


func _ready() -> void:
	_build_pylon(-HALF_SPAN)
	_build_pylon(HALF_SPAN)
	_build_banner()
	_build_lamp(-HALF_SPAN)
	_build_lamp(HALF_SPAN)


func _build_pylon(x: float) -> void:
	var pylon := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.3, PYLON_HEIGHT, 0.3)
	pylon.mesh = box
	pylon.position = Vector3(x, PYLON_HEIGHT * 0.5, 0.0)
	pylon.material_override = _pylon_material()
	pylon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(pylon)


func _build_banner() -> void:
	var banner := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(BANNER_SIZE.x, BANNER_SIZE.y, 0.14)
	banner.mesh = box
	banner.position = Vector3(0.0, BANNER_Y, 0.0)
	banner.material_override = _banner_material()
	banner.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(banner)


func _build_lamp(x: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(x, BANNER_Y - 0.1, 0.0)
	lamp.light_color = Color(1.0, 0.93, 0.78)
	lamp.light_energy = 1.1
	lamp.omni_range = 9.0
	lamp.shadow_enabled = false
	add_child(lamp)


func _pylon_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.92, 0.96)
	material.roughness = 0.55
	material.emission_enabled = true
	material.emission = Color(0.85, 0.9, 1.0)
	material.emission_energy_multiplier = 0.55
	return material


func _banner_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = FINISH_SHADER
	material.set_shader_parameter("squares", Vector2(18.0, 2.0))
	material.set_shader_parameter("color_a", Color(0.03, 0.03, 0.04))
	material.set_shader_parameter("color_b", Color(1.35, 1.35, 1.35))
	return material
