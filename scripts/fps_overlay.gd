extends CanvasLayer

var _label: Label
var _last_fps := -1


func _ready() -> void:
	layer = 128

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_label = Label.new()
	_label.offset_left = 14.0
	_label.offset_right = 160.0
	_label.offset_top = 8.0
	_label.offset_bottom = 34.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("outline_size", 4)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_label)

	_update_fps()


func _process(_delta: float) -> void:
	_update_fps()


func _update_fps() -> void:
	var fps := Engine.get_frames_per_second()
	if fps == _last_fps:
		return
	_last_fps = fps
	_label.text = "%d FPS" % fps
