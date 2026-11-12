extends Node3D

const TREE_COUNT := 240
const FERN_COUNT := 200
const NEAR_TREES := 70
const VINE_COUNT := 110
const Z_MIN := -80.0
const Z_MAX := 270.0
const ROAD_CLEARANCE := 7.0
const GROUND_SIZE := Vector2(180.0, 640.0)

var _canopy_material: StandardMaterial3D
var _built := false


func _ready() -> void:
	_build()


func configure(night: bool) -> void:
	if not _built:
		return
	_canopy_material.emission_enabled = night
	_canopy_material.emission_energy_multiplier = 0.3 if night else 0.0


func _build() -> void:
	_build_ground()
	_build_trees()
	_build_ferns()
	_build_vines()
	_built = true


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = GROUND_SIZE
	ground.mesh = mesh
	ground.position = Vector3(0.0, -0.07, 90.0)
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.04, 0.09, 0.035)
	material.roughness = 1.0
	ground.material_override = material
	add_child(ground)


func _build_trees() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 771131

	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.36
	trunk_mesh.bottom_radius = 0.62
	trunk_mesh.height = 1.0
	trunk_mesh.radial_segments = 6
	trunk_mesh.rings = 2

	var trunks := MultiMesh.new()
	trunks.transform_format = MultiMesh.TRANSFORM_3D
	trunks.use_colors = true
	trunks.mesh = trunk_mesh
	trunks.instance_count = TREE_COUNT

	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radius = 1.0
	canopy_mesh.height = 2.0
	canopy_mesh.radial_segments = 8
	canopy_mesh.rings = 5

	var canopies := MultiMesh.new()
	canopies.transform_format = MultiMesh.TRANSFORM_3D
	canopies.use_colors = true
	canopies.mesh = canopy_mesh
	canopies.instance_count = TREE_COUNT * 3

	var canopy_index := 0
	for i in TREE_COUNT:
		var side := -1.0 if i % 2 == 0 else 1.0
		var distance := rng.randf_range(ROAD_CLEARANCE, 17.0) if i < NEAR_TREES else rng.randf_range(17.0, 58.0)
		var x := side * distance
		var z := rng.randf_range(Z_MIN, Z_MAX)
		var height := rng.randf_range(16.0, 36.0)
		var thickness := rng.randf_range(0.35, 0.85)
		var bark := Color(0.17, 0.12, 0.09).lerp(Color(0.28, 0.22, 0.15), rng.randf())

		trunks.set_instance_transform(
			i,
			Transform3D(
				Basis.from_scale(Vector3(thickness, height, thickness)),
				Vector3(x, height * 0.5, z)
			)
		)
		trunks.set_instance_color(i, bark)

		var green := Color(0.03, 0.14, 0.04).lerp(Color(0.09, 0.28, 0.07), rng.randf())
		for layer in 3:
			var radius := rng.randf_range(3.2, 7.2)
			if i < NEAR_TREES:
				radius = minf(radius, distance * 0.45)
			var base := Vector3(x, height * (0.8 + 0.07 * layer), z)
			var offset := Vector3(rng.randf_range(-2.2, 2.2), 0.0, rng.randf_range(-2.2, 2.2))
			var blob := Basis.from_scale(Vector3(radius, radius * 0.5, radius))
			blob = blob.rotated(Vector3.UP, rng.randf() * TAU)
			canopies.set_instance_transform(canopy_index, Transform3D(blob, base + offset))
			canopies.set_instance_color(canopy_index, green.darkened(rng.randf_range(0.0, 0.2)))
			canopy_index += 1

	var trunk_material := StandardMaterial3D.new()
	trunk_material.albedo_color = Color(1.0, 1.0, 1.0)
	trunk_material.vertex_color_use_as_albedo = true
	trunk_material.roughness = 0.95

	var trunk_instance := MultiMeshInstance3D.new()
	trunk_instance.multimesh = trunks
	trunk_instance.material_override = trunk_material
	add_child(trunk_instance)

	_canopy_material = StandardMaterial3D.new()
	_canopy_material.albedo_color = Color(1.0, 1.0, 1.0)
	_canopy_material.vertex_color_use_as_albedo = true
	_canopy_material.roughness = 1.0
	_canopy_material.emission = Color(0.04, 0.14, 0.06)
	_canopy_material.emission_enabled = false

	var canopy_instance := MultiMeshInstance3D.new()
	canopy_instance.multimesh = canopies
	canopy_instance.material_override = _canopy_material
	add_child(canopy_instance)


func _build_ferns() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99117

	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 1.1
	cone.height = 2.0
	cone.radial_segments = 7
	cone.rings = 1

	var ferns := MultiMesh.new()
	ferns.transform_format = MultiMesh.TRANSFORM_3D
	ferns.use_colors = true
	ferns.mesh = cone
	ferns.instance_count = FERN_COUNT

	for i in FERN_COUNT:
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * rng.randf_range(5.2, 24.0)
		var z := rng.randf_range(Z_MIN, Z_MAX)
		var radius := rng.randf_range(0.5, 1.5)
		var height := radius * rng.randf_range(0.9, 1.5)
		var basis := Basis.from_scale(Vector3(radius, height, radius))
		basis = basis.rotated(Vector3.UP, rng.randf() * TAU)
		ferns.set_instance_transform(i, Transform3D(basis, Vector3(x, height, z)))
		ferns.set_instance_color(
			i, Color(0.06, 0.24, 0.06).lerp(Color(0.15, 0.38, 0.09), rng.randf())
		)

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 1.0, 1.0)
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0

	var instance := MultiMeshInstance3D.new()
	instance.multimesh = ferns
	instance.material_override = material
	add_child(instance)


func _build_vines() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 424242

	var vine_mesh := CylinderMesh.new()
	vine_mesh.top_radius = 0.04
	vine_mesh.bottom_radius = 0.07
	vine_mesh.height = 1.0
	vine_mesh.radial_segments = 4
	vine_mesh.rings = 1

	var vines := MultiMesh.new()
	vines.transform_format = MultiMesh.TRANSFORM_3D
	vines.mesh = vine_mesh
	vines.instance_count = VINE_COUNT

	for i in VINE_COUNT:
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * rng.randf_range(5.0, 20.0)
		var z := rng.randf_range(Z_MIN, Z_MAX)
		var length := rng.randf_range(4.0, 12.0)
		var top := rng.randf_range(14.0, 26.0)
		vines.set_instance_transform(
			i,
			Transform3D(
				Basis.from_scale(Vector3(1.0, length, 1.0)),
				Vector3(x, top - length * 0.5, z)
			)
		)

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.12, 0.3, 0.1)
	material.roughness = 1.0

	var instance := MultiMeshInstance3D.new()
	instance.multimesh = vines
	instance.material_override = material
	add_child(instance)
