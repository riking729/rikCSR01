extends Control

@export var images: Array[Texture2D] = []
@export var fade_duration := 1.2

@onready var _layer_a: TextureRect = $LayerA
@onready var _layer_b: TextureRect = $LayerB

var _base_layer: TextureRect
var _fade_layer: TextureRect
var _tween: Tween
var _current_index := -1


func _ready() -> void:
	if images.is_empty():
		return

	_current_index = _pick_index()
	_base_layer = _layer_a
	_fade_layer = _layer_b
	_layer_a.texture = images[_current_index]
	_layer_a.modulate.a = 0.0
	_layer_b.modulate.a = 0.0
	create_tween().tween_property(_layer_a, "modulate:a", 1.0, fade_duration)


func _on_timer_timeout() -> void:
	if images.size() < 2 or (_tween and _tween.is_running()):
		return

	_current_index = _pick_index()
	_fade_layer.texture = images[_current_index]
	_tween = create_tween()
	_tween.tween_property(_fade_layer, "modulate:a", 1.0, fade_duration)
	_tween.tween_callback(_promote_fade_layer)


func _promote_fade_layer() -> void:
	_base_layer.modulate.a = 0.0
	var previous := _base_layer
	_base_layer = _fade_layer
	_fade_layer = previous


func _pick_index() -> int:
	if images.size() < 2:
		return 0

	var index := randi() % images.size()
	while index == _current_index:
		index = randi() % images.size()
	return index
