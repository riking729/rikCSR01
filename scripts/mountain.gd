extends Node3D

const ENV_PRESETS := preload("res://scripts/environment_presets.gd")
const SNOW_SHADER := preload("res://shaders/snow_ground.gdshader")

const LENGTH := 460.0
const HALF_WIDTH := 15.0
const PLATFORM_HEIGHT := 3.4
const SNOW_LEVEL := -3.4
const PEAK_COUNT := 12
const PINE_COUNT := 54
const ROCK_COUNT := 46
const SIDES: Array[float] = [-1.0, 1.0]

var _snow_material: ShaderMaterial
var _rock_material: StandardMaterial3D
var _pine_material: StandardMaterial3D
var _snow_cap_material: StandardMaterial3D


func _ready() -> void:
	_build()


func _build() -> void:
	_snow_material = ShaderMaterial.new()
	_snow_material.shader = SNOW_SHADER

	_rock_material = StandardMaterial3D.new()
	_rock_material.albedo_color = Color(0.27, 0.3, 0.35)
	_rock_material.roughness = 0.92

	_pine_material = StandardMaterial3D.new()
	_pine_material.albedo_color = Color(0.045, 0.16, 0.13)
	_pine_material.roughness = 1.0

	_snow_cap_material = StandardMaterial3D.new()
	_snow_cap_material.albedo_color = Color(0.9, 0.95, 1.0)
	_snow_cap_material.roughness = 0.7

	var slope := Node3D.new()
	slope.name = "Slope"
	slope.rotation.z = ENV_PRESETS.mountain_tilt()
	add_child(slope)

	_build_platform(slope)
	_build_rocks(slope)
	_build_pines(slope)
	_build_valley()
	_build_ridge()
	_build_peaks()


func _build_platform(parent: Node3D) -> void:
	var platform := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(HALF_WIDTH * 2.0, PLATFORM_HEIGHT, LENGTH)
	platform.mesh = mesh
	platform.position = Vector3(0.0, -0.02 - PLATFORM_HEIGHT * 0.5, 0.0)
	platform.material_override = _snow_material
	parent.add_child(platform)

	for side in SIDES:
		var bank := MeshInstance3D.new()
		var bank_mesh := BoxMesh.new()
		bank_mesh.size = Vector3(2.4, 1.1, LENGTH)
		bank.mesh = bank_mesh
		bank.position = Vector3(side * (HALF_WIDTH - 1.0), 0.45, 0.0)
		bank.material_override = _snow_material
		parent.add_child(bank)


func _build_rocks(parent: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 64007

	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 6
	mesh.rings = 3

	var rocks := MultiMesh.new()
	rocks.transform_format = MultiMesh.TRANSFORM_3D
	rocks.use_colors = true
	rocks.mesh = mesh
	rocks.instance_count = ROCK_COUNT

	for i in ROCK_COUNT:
		var side := SIDES[i % SIDES.size()]
		var x := side * rng.randf_range(7.0, 14.0)
		var z := rng.randf_range(-70.0, 230.0)
		var scale := rng.randf_range(0.6, 2.2)
		var basis := Basis.from_scale(Vector3(scale, scale * rng.randf_range(0.5, 0.9), scale))
		basis = basis.rotated(Vector3.UP, rng.randf() * TAU)
		rocks.set_instance_transform(i, Transform3D(basis, Vector3(x, scale * 0.3, z)))
		rocks.set_instance_color(i, Color(0.3, 0.33, 0.38).lerp(Color(0.5, 0.54, 0.6), rng.randf()))

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 1.0)
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.9

	var instance := MultiMeshInstance3D.new()
	instance.multimesh = rocks
	instance.material_override = material
	parent.add_child(instance)


func _build_pines(parent: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 88331

	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 1.0
	cone.height = 1.0
	cone.radial_segments = 7
	cone.rings = 1

	var pines := MultiMesh.new()
	pines.transform_format = MultiMesh.TRANSFORM_3D
	pines.mesh = cone
	pines.instance_count = PINE_COUNT

	var caps := MultiMesh.new()
	caps.transform_format = MultiMesh.TRANSFORM_3D
	caps.mesh = cone
	caps.instance_count = PINE_COUNT

	for i in PINE_COUNT:
		var side := SIDES[i % SIDES.size()]
		var x := side * rng.randf_range(7.5, 13.5)
		var z := rng.randf_range(-70.0, 230.0)
		var height := rng.randf_range(3.0, 7.5)
		var radius := height * rng.randf_range(0.26, 0.36)
		pines.set_instance_transform(
			i,
			Transform3D(
				Basis.from_scale(Vector3(radius, height, radius)),
				Vector3(x, height * 0.5, z)
			)
		)
		caps.set_instance_transform(
			i,
			Transform3D(
				Basis.from_scale(Vector3(radius * 0.62, height * 0.3, radius * 0.62)),
				Vector3(x, height * 0.78, z)
			)
		)

	var pine_instance := MultiMeshInstance3D.new()
	pine_instance.multimesh = pines
	pine_instance.material_override = _pine_material
	parent.add_child(pine_instance)

	var cap_instance := MultiMeshInstance3D.new()
	cap_instance.multimesh = caps
	cap_instance.material_override = _snow_cap_material
	parent.add_child(cap_instance)


func _build_valley() -> void:
	var field := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(1600.0, 1600.0)
	field.mesh = mesh
	field.position = Vector3(0.0, SNOW_LEVEL, 90.0)
	field.material_override = _snow_material
	field.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(field)


func _build_ridge() -> void:
	var ridge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(110.0, 1.2, 700.0)
	ridge.mesh = mesh
	ridge.position = Vector3(69.0, 18.3, 80.0)
	ridge.rotation.z = deg_to_rad(18.0)
	ridge.material_override = _snow_material
	add_child(ridge)


func _build_peaks() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 55123

	for i in PEAK_COUNT:
		var peak := MeshInstance3D.new()
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.0
		mesh.bottom_radius = rng.randf_range(65.0, 125.0)
		mesh.height = rng.randf_range(100.0, 200.0)
		mesh.radial_segments = 7
		mesh.rings = 1
		peak.mesh = mesh
		peak.position = Vector3(
			rng.randf_range(-300.0, 260.0), -20.0, rng.randf_range(250.0, 460.0)
		)
		peak.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.62, 0.7, 0.82).lerp(Color(0.82, 0.88, 0.96), rng.randf())
		material.roughness = 0.65
		peak.material_override = material
		add_child(peak)
