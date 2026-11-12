extends Control

const NODE_SIZE := Vector2(150, 240)
const NODE_GAP := 70.0
const CIRCLE_Y := 70.0
const CIRCLE_R := 34.0

const WON_FILL := Color(0.10, 0.24, 0.13)
const WON_BORDER := Color(0.35, 0.75, 0.4)
const CURRENT_FILL := Color(0.24, 0.16, 0.06)
const ACCENT := Color(1.0, 0.78, 0.3)
const LOCKED_FILL := Color(0.09, 0.09, 0.10)
const LOCKED_BORDER := Color(0.32, 0.32, 0.35)

var nodes: Array = []
var _won := 0


func build(count: int, won: int, make_node: Callable) -> void:
	_won = won
	for child in get_children():
		child.queue_free()
	nodes.clear()
	for i in count:
		var node := make_node.call(i) as Control
		node.position = Vector2(24 + i * (NODE_SIZE.x + NODE_GAP), 0)
		node.size = NODE_SIZE
		add_child(node)
		nodes.append(node)
	custom_minimum_size = Vector2(
		48 + count * NODE_SIZE.x + (count - 1) * NODE_GAP, NODE_SIZE.y
	)
	size = custom_minimum_size
	queue_redraw()


func _draw() -> void:
	if nodes.size() < 2:
		return
	for i in nodes.size() - 1:
		var center_a: Vector2 = nodes[i].position + Vector2(NODE_SIZE.x * 0.5, CIRCLE_Y)
		var center_b: Vector2 = nodes[i + 1].position + Vector2(NODE_SIZE.x * 0.5, CIRCLE_Y)
		var color := Color(0.2, 0.2, 0.23)
		if i < _won:
			color = WON_BORDER
		elif i == _won:
			color = ACCENT
		draw_line(
			center_a + Vector2(CIRCLE_R, 0), center_b - Vector2(CIRCLE_R, 0), color, 4.0
		)


class LadderNode extends Control:
	var index := 0
	var state := "locked"
	var prize_text := ""
	var gold_text := ""
	var hovered := false
	var pulse := 0.0

	const SIZE := Vector2(150, 240)
	const CIRCLE_Y := 70.0
	const CIRCLE_R := 34.0
	const WON_FILL := Color(0.10, 0.24, 0.13)
	const WON_BORDER := Color(0.35, 0.75, 0.4)
	const CURRENT_FILL := Color(0.24, 0.16, 0.06)
	const ACCENT := Color(1.0, 0.78, 0.3)
	const LOCKED_FILL := Color(0.09, 0.09, 0.10)
	const LOCKED_BORDER := Color(0.32, 0.32, 0.35)

	func setup(p_index: int, p_state: String, p_prize: String, p_gold: String) -> void:
		index = p_index
		state = p_state
		prize_text = p_prize
		gold_text = p_gold
		custom_minimum_size = SIZE
		size = SIZE
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_ALL
		mouse_entered.connect(_set_hovered.bind(true))
		mouse_exited.connect(_set_hovered.bind(false))
		focus_entered.connect(queue_redraw)
		focus_exited.connect(queue_redraw)

	func _set_hovered(value: bool) -> void:
		hovered = value
		queue_redraw()

	func _draw() -> void:
		var center := Vector2(size.x * 0.5, CIRCLE_Y)
		var fill: Color = LOCKED_FILL
		var border: Color = LOCKED_BORDER
		var font_color := Color(0.5, 0.52, 0.56)
		match state:
			"won":
				fill = WON_FILL
				border = WON_BORDER
				font_color = Color(0.85, 0.95, 0.85)
			"current":
				fill = CURRENT_FILL
				border = ACCENT
				font_color = Color(1.0, 0.95, 0.8)

		var border_width := 3.0
		if state == "current":
			border_width = 4.0 + pulse * 2.0
		draw_circle(center, CIRCLE_R, fill)
		draw_arc(center, CIRCLE_R, 0.0, TAU, 48, border, border_width, true)

		var font := get_theme_default_font()
		var text := str(index + 1)
		var ascent := font.get_ascent(30)
		var descent := font.get_descent(30)
		var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 30).x
		var baseline := center + Vector2(-text_width * 0.5, (ascent - descent) * 0.5)
		draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 30, font_color)

		if state == "current":
			_draw_info_box(center)

	func _draw_info_box(center: Vector2) -> void:
		if not hovered and not has_focus():
			return
		var box := Rect2(
			Vector2((size.x - 190) * 0.5, center.y + CIRCLE_R + 14), Vector2(190, 62)
		)
		draw_rect(box, Color(0.05, 0.05, 0.07, 0.97))
		draw_rect(box, ACCENT, false, 2.0)
		var font := get_theme_default_font()
		draw_string(
			font, box.position + Vector2(12, 25), prize_text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.92, 0.94, 1.0)
		)
		draw_string(
			font, box.position + Vector2(12, 48), "+" + gold_text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1.0, 0.85, 0.4)
		)
