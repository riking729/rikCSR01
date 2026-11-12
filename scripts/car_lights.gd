extends RefCounted

const LampData := preload("res://scripts/car_lamp_data.gd")

const HEAD_COLOR := Color(1.0, 0.93, 0.76)
const TAIL_COLOR := Color(1.0, 0.12, 0.07)
const HOVER_HEAD_COLOR := Color(0.55, 0.9, 1.0)
const HOVER_TAIL_COLOR := Color(1.0, 0.3, 0.65)

const FRONT_BAND := 0.25
const REAR_BAND := 0.25
const LAMP_DROP := 0.2
const LENS_THICKNESS := 0.028

static var _lens_material: StandardMaterial3D
static var _tail_material: StandardMaterial3D


static func attach(car: Node3D, night: bool) -> void:
	if car == null or car.has_node("CarLights") or not night:
		return
	# Open-wheel racer: no lamps to match, so no add-on lights.
	if String(car.scene_file_path).get_file() == "CarRaceCar.tscn":
		return
	var surfaces := _surfaces(car)
	if surfaces.is_empty():
		return

	var root := Node3D.new()
	root.name = "CarLights"
	car.add_child(root)

	var head := _by_material(surfaces, ["headlight"])
	var tail := _by_material(surfaces, ["taillight", "tail_lights", "tail_light"])
	if not head.is_empty():
		_attach_modelled(root, head, tail)
		_add_table_tail(car, root, surfaces)
		return

	var glow_head := _by_node(surfaces, "headlights_glow")
	if not glow_head.is_empty():
		_attach_glow(root, glow_head, _by_node(surfaces, "taillights_glow"))
		return

	_attach_painted(car, root, surfaces)


# Cars with dedicated light geometry (Grab3D pack).
static func _attach_modelled(
	root: Node3D, head: Array[Dictionary], tail: Array[Dictionary]
) -> void:
	_emissive(head, HEAD_COLOR, 2.4)

	var front := _split_sides(_points(head))
	for side in front:
		var spot_pos: Vector3 = front[side]
		spot_pos.z += 0.02
		_add_spot(root, spot_pos)

	var tail_points := _points(tail)
	if _tail_surface_clean(tail_points):
		_emissive(tail, TAIL_COLOR, 1.6)
		return
	# Some models reuse the tail material on unrelated parts (e.g. the light
	# bar of the police car): light only the rear clusters instead.
	var rear := _split_sides(tail_points)
	for side in rear:
		var pos: Vector3 = rear[side]
		pos.z -= 0.012
		_add_lens(root, pos, Vector3(0.16, 0.1, LENS_THICKNESS), _tail())


# Hover car: the model already owns glowing headlight/taillight strips.
static func _attach_glow(
	root: Node3D, head: Array[Dictionary], tail: Array[Dictionary]
) -> void:
	_emissive(head, HOVER_HEAD_COLOR, 2.0)
	_emissive(tail, HOVER_TAIL_COLOR, 1.4)
	var front := _split_sides(_points(head))
	for side in front:
		_add_spot(root, front[side])


# Painted-light models: place lenses on the actual painted front/rear lamps.
static func _attach_painted(car: Node3D, root: Node3D, surfaces: Array[Dictionary]) -> void:
	if String(car.scene_file_path).get_file() == "CarTukTuk.tscn":
		_attach_tuktuk(root, surfaces)
		return

	var body := _largest(surfaces)
	if body.is_empty():
		return
	var key := _body_key(surfaces)
	var head_lamp: Variant = LampData.HEADS.get(key) if not (key in LampData.NO_HEAD) else null
	var tail_lamp: Variant = LampData.TAILS.get(key) if not (key in LampData.NO_TAIL) else null
	var cloud := _world_verts(body)
	var box := _aabb(cloud)
	if box.size.z <= 0.0 or box.size.x <= 0.0:
		return

	var half_w := box.size.x * 0.5
	var length := box.size.z
	var lens_w := clampf(box.size.x * 0.075, 0.09, 0.26)
	var drop := clampf(box.size.y * 0.13, 0.16, 0.26)

	if head_lamp == null and not (key in LampData.NO_HEAD):
		for side in [-1.0, 1.0]:
			var lamp := _lamp_point(cloud, side, box, true, half_w, length, drop)
			if lamp.is_empty():
				continue
			var pos: Vector3 = lamp["pos"]
			var w: float = maxf(lens_w, float(lamp["width"]) * 1.05)
			_add_lens(root, pos, Vector3(w, lens_w * 0.56, LENS_THICKNESS), _lens())
			_add_spot(root, pos + Vector3(0.0, 0.02, 0.06))
	elif head_lamp != null:
		_add_table_pair(root, head_lamp, true)

	if tail_lamp != null:
		_add_table_pair(root, tail_lamp, false)
	elif not (key in LampData.NO_TAIL):
		for side in [-1.0, 1.0]:
			var rear := _lamp_point(cloud, side, box, false, half_w, length, drop * 0.9)
			if rear.is_empty():
				continue
			var rpos: Vector3 = rear["pos"]
			var rw: float = maxf(lens_w * 1.15, float(rear["width"]) * 1.05)
			_add_lens(root, rpos, Vector3(rw, lens_w * 0.45, LENS_THICKNESS), _tail())


static func _body_key(surfaces: Array[Dictionary]) -> String:
	for entry in surfaces:
		var name: String = entry["name"]
		if name.ends_with("_body_pbr"):
			return name.trim_suffix("_body_pbr")
	return ""


static func _add_table_pair(root: Node3D, lamp: Array, front: bool) -> void:
	var x := float(lamp[0])
	var y := float(lamp[1])
	var z := float(lamp[2])
	var w := float(lamp[3])
	var h := float(lamp[4])
	var offset := LENS_THICKNESS * 0.5 + 0.004
	var material := _lens() if front else _tail()
	var round := maxf(w, h) <= 0.22 and w / h >= 0.74 and w / h <= 1.35
	for side in [-1.0, 1.0]:
		var pos := Vector3(side * x, y, z + offset if front else z - offset)
		if round:
			_add_disc(root, pos, w, h, material)
		else:
			_add_lens(root, pos, Vector3(w, h, LENS_THICKNESS), material)
		if front:
			_add_spot(root, pos + Vector3(0.0, 0.02, 0.06))


static func _add_table_tail(car: Node3D, root: Node3D, surfaces: Array[Dictionary]) -> void:
	var key := _body_key(surfaces)
	var lamp: Variant = LampData.TAILS.get(key)
	if lamp != null:
		_add_table_pair(root, lamp, false)


static func _attach_tuktuk(root: Node3D, surfaces: Array[Dictionary]) -> void:
	var body := _largest(surfaces)
	if body.is_empty():
		return
	var cloud := _world_verts(body)
	var box := _aabb(cloud)
	var half_w := box.size.x * 0.5
	var height := box.size.y

	var lamp_y := box.position.y + height * 0.3
	var lamp_z := -INF
	for p in cloud:
		if absf(p.x) > 0.16 or absf(p.y - lamp_y) > 0.12:
			continue
		if p.z > box.position.z + box.size.z * 0.4:
			lamp_z = maxf(lamp_z, p.z)
	if lamp_z == -INF:
		lamp_z = box.position.z + box.size.z
	_add_lens(
		root, Vector3(0.0, lamp_y, lamp_z + LENS_THICKNESS * 0.5 + 0.006),
		Vector3(0.13, 0.11, LENS_THICKNESS), _lens()
	)
	_add_spot(root, Vector3(0.0, lamp_y + 0.02, lamp_z + 0.07))

	var tail_y := box.position.y + height * 0.13
	for side: float in [-1.0, 1.0]:
		var x := side * half_w * 0.75
		var rear_z := INF
		for p in cloud:
			if absf(p.x - x) > 0.2 or absf(p.y - tail_y) > 0.14:
				continue
			if p.z < box.position.z + box.size.z * 0.6:
				rear_z = minf(rear_z, p.z)
		if rear_z == INF:
			rear_z = box.position.z
		_add_lens(
			root, Vector3(x, tail_y, rear_z - LENS_THICKNESS * 0.5 - 0.006),
			Vector3(0.12, 0.09, LENS_THICKNESS), _tail()
		)


static func _tail_surface_clean(points: PackedVector3Array) -> bool:
	if points.is_empty():
		return false
	var box := _aabb(points)
	return box.size.z <= 0.5


static func _lamp_point(
	cloud: PackedVector3Array,
	side: float,
	box: AABB,
	front: bool,
	half_w: float,
	length: float,
	drop: float
) -> Dictionary:
	var zmin := box.position.z
	var zmax := box.position.z + box.size.z
	var band_z := length * (FRONT_BAND if front else REAR_BAND)
	var side_pts := PackedVector3Array()
	for p in cloud:
		if signf(p.x) != side:
			continue
		if front and p.z < zmax - band_z:
			continue
		if not front and p.z > zmin + band_z:
			continue
		if absf(p.x) < half_w * 0.5 or absf(p.x) > half_w:
			continue
		side_pts.append(p)
	if side_pts.is_empty():
		return {}

	var ys := PackedFloat32Array()
	for p in side_pts:
		ys.append(p.y)
	ys.sort()
	var top := ys[int(ys.size() * 0.9)]
	var lamp_y := top - drop

	var outer := 0.0
	var cap := PackedVector3Array()
	for p in side_pts:
		if absf(p.y - lamp_y) > 0.09:
			continue
		outer = maxf(outer, absf(p.x))
	if outer <= 0.0:
		for p in side_pts:
			outer = maxf(outer, absf(p.x))

	var lens_w := clampf(box.size.x * 0.075, 0.09, 0.26)
	var x := maxf(outer - lens_w * 0.85, lens_w * 0.55)
	x *= side

	var snap_z := zmax if front else zmin
	var found := false
	for radius in [0.14, 0.22, 0.34]:
		var best := -INF if front else INF
		for p in cloud:
			if absf(p.x - x) > radius or absf(p.y - lamp_y) > radius * 0.8:
				continue
			if front and p.z < box.position.z + box.size.z * 0.35:
				continue
			if not front and p.z > box.position.z + box.size.z * 0.65:
				continue
			best = maxf(best, p.z) if front else minf(best, p.z)
			found = true
		if found:
			snap_z = best
			break

	cap = PackedVector3Array()
	for p in cloud:
		if absf(p.x - x) > 0.16 or absf(p.y - lamp_y) > 0.1:
			continue
		if front and p.z >= snap_z - 0.1:
			cap.append(p)
		elif not front and p.z <= snap_z + 0.1:
			cap.append(p)

	var width := lens_w
	if not cap.is_empty():
		var cbox := _aabb(cap)
		lamp_y = cbox.position.y + cbox.size.y * 0.5
		width = clampf(cbox.size.x, lens_w * 0.7, lens_w * 1.4)

	var depth := LENS_THICKNESS
	var pos := Vector3(
		x,
		lamp_y,
		snap_z + (depth * 0.5 + 0.004) if front else snap_z - (depth * 0.5 + 0.004)
	)
	return {"pos": pos, "width": width}


static func _split_sides(points: PackedVector3Array) -> Dictionary:
	var left := PackedVector3Array()
	var right := PackedVector3Array()
	for p in points:
		if p.x >= 0.0:
			right.append(p)
		else:
			left.append(p)

	var bl := _aabb(left)
	var br := _aabb(right)
	var use_left := true
	if left.is_empty():
		use_left = false
	elif not right.is_empty():
		var vl := _volume(bl)
		var vr := _volume(br)
		var dirty_left := left.size() > right.size() * 2.0 or vl > vr * 4.0
		var dirty_right := right.size() > left.size() * 2.0 or vr > vl * 4.0
		use_left = not dirty_left or dirty_right

	var ref := left if use_left else right
	if ref.is_empty():
		return {}

	var center := _aabb(ref).get_center()
	var out := {}
	for side in [-1.0, 1.0]:
		out[side] = Vector3(side * absf(center.x), center.y, center.z)
	return out


static func _emissive(surfaces: Array[Dictionary], color: Color, energy: float) -> void:
	for entry in surfaces:
		var mesh_instance := entry["mi"] as MeshInstance3D
		var surface := int(entry["surface"])
		var base := entry["mat"] as Material
		var material: StandardMaterial3D
		if base is StandardMaterial3D:
			material = (base as StandardMaterial3D).duplicate() as StandardMaterial3D
		else:
			material = StandardMaterial3D.new()
			material.albedo_color = color
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = energy
		mesh_instance.set_surface_override_material(surface, material)


static func _surfaces(car: Node3D) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var inverse := car.global_transform.affine_inverse()
	for node in car.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		if not (mesh_instance.mesh is ArrayMesh):
			continue
		var relative := inverse * mesh_instance.global_transform
		for surface in mesh_instance.mesh.get_surface_count():
			var arrays := mesh_instance.mesh.surface_get_arrays(surface)
			if arrays.is_empty():
				continue
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			if verts.is_empty():
				continue
			var material := mesh_instance.mesh.surface_get_material(surface)
			var material_name := ""
			if material != null:
				material_name = String(material.resource_name)
			out.append({
				"mi": mesh_instance,
				"surface": surface,
				"rel": relative,
				"verts": verts,
				"count": verts.size(),
				"mat": material,
				"name": material_name.to_lower(),
				"node": String(mesh_instance.name).to_lower(),
			})
	return out


static func _by_material(surfaces: Array[Dictionary], needles: Array) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry in surfaces:
		var name: String = entry["name"]
		for needle in needles:
			if name.contains(needle):
				out.append(entry)
				break
	return out


static func _by_node(surfaces: Array[Dictionary], needle: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry in surfaces:
		if String(entry["node"]).contains(needle):
			out.append(entry)
	return out


static func _largest(surfaces: Array[Dictionary]) -> Dictionary:
	var best: Dictionary = {}
	for entry in surfaces:
		if best.is_empty() or int(entry["count"]) > int(best["count"]):
			best = entry
	return best


static func _points(surfaces: Array[Dictionary]) -> PackedVector3Array:
	var out := PackedVector3Array()
	for entry in surfaces:
		out.append_array(_world_verts(entry))
	return out


static func _world_verts(entry: Dictionary) -> PackedVector3Array:
	var relative: Transform3D = entry["rel"]
	var source: PackedVector3Array = entry["verts"]
	var out := PackedVector3Array()
	out.resize(source.size())
	for i in source.size():
		out[i] = relative * source[i]
	return out


static func _aabb(points: PackedVector3Array) -> AABB:
	if points.is_empty():
		return AABB()
	var box := AABB(points[0], Vector3.ZERO)
	for p in points:
		box = box.expand(p)
	return box


static func _volume(box: AABB) -> float:
	return box.size.x * box.size.y * box.size.z


static func _add_lens(
	root: Node3D, pos: Vector3, size: Vector3, material: StandardMaterial3D
) -> void:
	var lens := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	lens.mesh = box
	lens.material_override = material
	lens.position = pos
	lens.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(lens)


static func _add_disc(
	root: Node3D, pos: Vector3, w: float, h: float, material: StandardMaterial3D
) -> void:
	var lens := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.5
	disc.bottom_radius = 0.5
	disc.height = 1.0
	disc.radial_segments = 16
	disc.rings = 1
	lens.mesh = disc
	lens.material_override = material
	lens.position = pos
	lens.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	lens.scale = Vector3(w, LENS_THICKNESS, h)
	lens.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(lens)


static func _add_spot(root: Node3D, pos: Vector3) -> void:
	var spot := SpotLight3D.new()
	spot.position = pos
	spot.rotation_degrees = Vector3(-6, 180, 0)
	spot.light_color = Color(1.0, 0.94, 0.8)
	spot.light_energy = 3.0
	spot.spot_range = 30.0
	spot.spot_angle = 26.0
	spot.light_specular = 0.3
	spot.shadow_enabled = false
	root.add_child(spot)


static func _lens() -> StandardMaterial3D:
	if _lens_material == null:
		_lens_material = StandardMaterial3D.new()
		_lens_material.albedo_color = Color(0.95, 0.88, 0.68)
		_lens_material.emission_enabled = true
		_lens_material.emission = HEAD_COLOR
		_lens_material.emission_energy_multiplier = 2.8
		_lens_material.roughness = 0.25
	return _lens_material


static func _tail() -> StandardMaterial3D:
	if _tail_material == null:
		_tail_material = StandardMaterial3D.new()
		_tail_material.albedo_color = Color(0.5, 0.06, 0.05)
		_tail_material.emission_enabled = true
		_tail_material.emission = TAIL_COLOR
		_tail_material.emission_energy_multiplier = 1.5
		_tail_material.roughness = 0.3
	return _tail_material
