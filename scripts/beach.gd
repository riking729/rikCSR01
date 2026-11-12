extends Node3D

const SAND_SHADER := preload("res://shaders/beach_sand.gdshader")
const SEA_SHADER := preload("res://shaders/sea_water.gdshader")

const LENGTH := 460.0
const HALF_WIDTH := 13.0
const SEA_LEVEL := -1.5
const RAIL_X := 12.5
const POST_SPACING := 5.0
const LAMP_Z_START := -80.0
const LAMP_Z_END := 200.0
const LAMP_SPACING := 40.0
const SIDES: Array[float] = [-1.0, 1.0]

var _sand_material: ShaderMaterial
var _sea_material: ShaderMaterial
var _rail_material: StandardMaterial3D
var _pole_material: StandardMaterial3D
var _lamp_material: StandardMaterial3D
var _lamp_lights: Array[OmniLight3D] = []
var _built := false


func _ready() -> void:
	_build()
	configure(false)


func configure(night: bool) -> void:
	if not _built:
		return
	_sand_material.set_shader_parameter("night", 1.0 if night else 0.0)
	_sea_material.set_shader_parameter("night", 1.0 if night else 0.0)
	_lamp_material.emission_energy_multiplier = 5.0 if night else 0.0
	for light in _lamp_lights:
		light.visible = night


func _build() -> void:
	_sand_material = ShaderMaterial.new()
	_sand_material.shader = SAND_SHADER

	_sea_material = ShaderMaterial.new()
	_sea_material.shader = SEA_SHADER

	_rail_material = StandardMaterial3D.new()
	_rail_material.albedo_color = Color(0.9, 0.9, 0.88)
	_rail_material.roughness = 0.45
	_rail_material.metallic = 0.2

	_pole_material = StandardMaterial3D.new()
	_pole_material.albedo_color = Color(0.16, 0.19, 0.22)
	_pole_material.roughness = 0.6

	_lamp_material = StandardMaterial3D.new()
	_lamp_material.albedo_color = Color(1.0, 0.82, 0.45)
	_lamp_material.emission_enabled = true
	_lamp_material.emission = Color(1.0, 0.8, 0.42)
	_lamp_material.emission_energy_multiplier = 0.0
	_lamp_material.roughness = 0.4

	_build_quay()
	_build_sea()
	_build_railings()
	_build_lamps()
	_built = true


func _build_quay() -> void:
	var quay := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(HALF_WIDTH * 2.0, 1.6, LENGTH)
	quay.mesh = mesh
	quay.position = Vector3(0.0, -0.82, 0.0)
	quay.material_override = _sand_material
	add_child(quay)


func _build_sea() -> void:
	var sea := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(1800.0, 1800.0)
	sea.mesh = mesh
	sea.position = Vector3(0.0, SEA_LEVEL, 0.0)
	sea.material_override = _sea_material
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sea)


func _build_railings() -> void:
	var count_per_side := int(LENGTH / POST_SPACING) + 1
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var post := BoxMesh.new()
	post.size = Vector3(0.1, 0.95, 0.1)
	multimesh.mesh = post
	multimesh.instance_count = count_per_side * SIDES.size()
	var index := 0
	for side in SIDES:
		for i in count_per_side:
			var z := -LENGTH * 0.5 + i * POST_SPACING
			var xform := Transform3D(Basis.IDENTITY, Vector3(side * RAIL_X, 0.46, z))
			multimesh.set_instance_transform(index, xform)
			index += 1

	var posts := MultiMeshInstance3D.new()
	posts.multimesh = multimesh
	posts.material_override = _rail_material
	add_child(posts)

	for side in SIDES:
		var rail := MeshInstance3D.new()
		var bar := BoxMesh.new()
		bar.size = Vector3(0.09, 0.09, LENGTH)
		rail.mesh = bar
		rail.position = Vector3(side * RAIL_X, 0.95, 0.0)
		rail.material_override = _rail_material
		add_child(rail)


func _build_lamps() -> void:
	var z := LAMP_Z_START
	while z <= LAMP_Z_END:
		for side in SIDES:
			_add_lamp(Vector3(side * (RAIL_X - 0.9), 0.0, z))
		z += LAMP_SPACING


func _add_lamp(base: Vector3) -> void:
	var pole := MeshInstance3D.new()
	var pole_mesh := BoxMesh.new()
	pole_mesh.size = Vector3(0.14, 4.2, 0.14)
	pole.mesh = pole_mesh
	pole.position = base + Vector3(0.0, 2.1, 0.0)
	pole.material_override = _pole_material
	add_child(pole)

	var orb := MeshInstance3D.new()
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.24
	orb_mesh.height = 0.48
	orb.mesh = orb_mesh
	orb.position = base + Vector3(0.0, 4.35, 0.0)
	orb.material_override = _lamp_material
	add_child(orb)

	var light := OmniLight3D.new()
	light.position = base + Vector3(0.0, 4.1, 0.0)
	light.light_color = Color(1.0, 0.82, 0.55)
	light.light_energy = 1.7
	light.omni_range = 34.0
	light.shadow_enabled = false
	light.visible = false
	add_child(light)
	_lamp_lights.append(light)
