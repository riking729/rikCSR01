extends Node3D

const PAINT_SHADER := preload("res://shaders/car_paint.gdshader")
const PAINT_TEXTURE := preload("res://models/car/Textures/colormap.png")

@export var recolor := false
@export var paint_color: Color = Color(1.0, 0.55, 0.12)


func _ready() -> void:
	if not recolor:
		return

	var body := get_node_or_null("Model/body") as MeshInstance3D
	if body == null:
		return

	var material := ShaderMaterial.new()
	material.shader = PAINT_SHADER
	material.set_shader_parameter("albedo_texture", PAINT_TEXTURE)
	material.set_shader_parameter("target_hue", paint_color.h)
	material.set_shader_parameter("target_saturation", paint_color.s)
	body.material_override = material
