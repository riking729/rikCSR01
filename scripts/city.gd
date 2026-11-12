extends Node3D

const LENGTH := 460.0
const SEED := 20261111
const BUILDING_SHADER := preload("res://shaders/building_windows.gdshader")

const PALETTE: Array[Color] = [
	Color(0.45, 0.21, 0.20),
	Color(0.18, 0.34, 0.38),
	Color(0.47, 0.35, 0.16),
	Color(0.22, 0.29, 0.45),
	Color(0.33, 0.22, 0.40),
	Color(0.22, 0.36, 0.26),
	Color(0.50, 0.28, 0.16),
	Color(0.30, 0.32, 0.35),
	Color(0.40, 0.25, 0.30),
	Color(0.20, 0.31, 0.35),
]

var _rng := RandomNumberGenerator.new()
var _mesh: BoxMesh
var _materials_near: Array[ShaderMaterial] = []
var _materials_far: Array[ShaderMaterial] = []


func _ready() -> void:
	_rng.seed = SEED
	_mesh = BoxMesh.new()
	_mesh.size = Vector3.ONE
	for color in PALETTE:
		_materials_near.append(_make_material(color))
		_materials_far.append(_make_material(color.darkened(0.35)))

	_build_near(-1.0)
	_build_near(1.0)
	_build_far(-1.0)
	_build_far(1.0)


func _build_near(side: float) -> void:
	var z := -LENGTH * 0.5
	while z < LENGTH * 0.5:
		var width := _rng.randf_range(6.0, 12.0)
		var depth := _rng.randf_range(8.0, 18.0)
		var height := _rng.randf_range(8.0, 26.0)
		var inner := _rng.randf_range(7.0, 12.0)
		_add_building(
			side * (inner + width * 0.5), z + depth * 0.5, width, height, depth, _materials_near
		)
		z += depth + _rng.randf_range(4.0, 14.0)


func _build_far(side: float) -> void:
	var z := -LENGTH * 0.5
	while z < LENGTH * 0.5:
		var width := _rng.randf_range(10.0, 20.0)
		var depth := _rng.randf_range(12.0, 24.0)
		var height := _rng.randf_range(28.0, 70.0)
		var inner := _rng.randf_range(26.0, 46.0)
		_add_building(
			side * (inner + width * 0.5), z + depth * 0.5, width, height, depth, _materials_far
		)
		z += depth + _rng.randf_range(6.0, 22.0)


func _add_building(
	x: float,
	z: float,
	width: float,
	height: float,
	depth: float,
	materials: Array[ShaderMaterial]
) -> void:
	var building := MeshInstance3D.new()
	building.mesh = _mesh
	building.scale = Vector3(width, height, depth)
	building.position = Vector3(x, height * 0.5, z)
	building.material_override = materials[_rng.randi() % materials.size()]
	building.set_instance_shader_parameter("building_size", Vector3(width, height, depth))
	add_child(building)


func _make_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = BUILDING_SHADER
	material.set_shader_parameter("wall_color", color)
	material.set_shader_parameter("window_color", Color(1.0, 0.8, 0.35))
	material.set_shader_parameter("floor_height", 3.4)
	material.set_shader_parameter("window_energy", 1.8)
	return material
