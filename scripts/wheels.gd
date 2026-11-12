extends Node3D

@export var wheel_paths: Array[NodePath] = []
@export var wheel_radius := 0.35
@export var spin_direction := 1.0

var _spin := 0.0
var _wheels: Array[Node3D] = []
var _bases: Array[Transform3D] = []
var _pivots: Array[Vector3] = []


func _ready() -> void:
	for path in wheel_paths:
		var wheel := get_node_or_null(path) as Node3D
		if wheel == null:
			push_warning("Wheel not found: %s" % path)
			continue
		_wheels.append(wheel)
		_bases.append(wheel.transform)
		_pivots.append(_wheel_center(wheel))


func _wheel_center(wheel: Node3D) -> Vector3:
	var box := AABB()
	var found := false
	if wheel is MeshInstance3D:
		box = (wheel as MeshInstance3D).get_aabb()
		found = true
	else:
		for child in wheel.get_children():
			if child is MeshInstance3D:
				var child_box: AABB = (child as MeshInstance3D).get_aabb()
				box = child_box if not found else box.merge(child_box)
				found = true
	return box.get_center() if found else Vector3.ZERO


func spin_wheels(distance: float) -> void:
	_spin += spin_direction * distance / wheel_radius
	var rotation := Basis(Vector3.RIGHT, _spin)
	for index in _wheels.size():
		var pivot := _pivots[index]
		_wheels[index].transform = _bases[index] * Transform3D(rotation, pivot - rotation * pivot)
