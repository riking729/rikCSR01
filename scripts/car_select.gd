extends Node3D

const CAR_IDS: Array[String] = [
	"coupe", "sports", "sedan", "city", "police", "taxi", "suv",
	"sedan_50", "wagon_50", "pickup_50", "roadster_50",
	"convertible_60", "compact_60", "microbus_60", "sports_60",
	"coupe_70", "hatchback_70", "pickup_70", "sedan_70",
	"hatchback_80", "sedan_80", "sports_80",
	"wagon_80", "van_80", "compact_90", "van_90", "hatchback_90",
	"minivan_90", "offroad_90", "pickup_90", "police_90", "sedan_90",
	"sports_90", "wagon_90", "suv_90", "taxi_90", "atomic", "compact",
	"convertible", "coupe_modern", "buggy", "electric", "lowrider",
	"microcar", "minivan", "muscle", "rally", "wagon", "limo", "tuk_tuk",
	"classic", "hatchback", "hover", "police_modern",
	"race_car", "sedan_modern", "sports_modern", "suv_modern", "taxi_modern",
]
const CAR_SCENES := {
	"coupe": preload("res://scenes/CarCoupe.tscn"),
	"sports": preload("res://scenes/CarSports.tscn"),
	"sedan": preload("res://scenes/CarSedan.tscn"),
	"city": preload("res://scenes/CarCity.tscn"),
	"police": preload("res://scenes/CarPolice.tscn"),
	"taxi": preload("res://scenes/CarTaxi.tscn"),
	"suv": preload("res://scenes/CarSUV.tscn"),
	"sedan_50": preload("res://scenes/CarSedan50.tscn"),
	"wagon_50": preload("res://scenes/CarWagon50.tscn"),
	"pickup_50": preload("res://scenes/CarPickup50.tscn"),
	"roadster_50": preload("res://scenes/CarRoadster50.tscn"),
	"convertible_60": preload("res://scenes/CarConvertible60.tscn"),
	"compact_60": preload("res://scenes/CarCompact60.tscn"),
	"microbus_60": preload("res://scenes/CarMicrobus60.tscn"),
	"sports_60": preload("res://scenes/CarSports60.tscn"),
	"coupe_70": preload("res://scenes/CarCoupe70.tscn"),
	"hatchback_70": preload("res://scenes/CarHatchback70.tscn"),
	"pickup_70": preload("res://scenes/CarPickup70.tscn"),
	"sedan_70": preload("res://scenes/CarSedan70.tscn"),
	"hatchback_80": preload("res://scenes/CarHatchback80.tscn"),
	"sedan_80": preload("res://scenes/CarSedan80.tscn"),
	"sports_80": preload("res://scenes/CarSports80.tscn"),
	"wagon_80": preload("res://scenes/CarWagon80.tscn"),
	"van_80": preload("res://scenes/CarVan80.tscn"),
	"compact_90": preload("res://scenes/CarCompact90.tscn"),
	"van_90": preload("res://scenes/CarVan90.tscn"),
	"hatchback_90": preload("res://scenes/CarHatchback90.tscn"),
	"minivan_90": preload("res://scenes/CarMinivan90.tscn"),
	"offroad_90": preload("res://scenes/CarOffroad90.tscn"),
	"pickup_90": preload("res://scenes/CarPickup90.tscn"),
	"police_90": preload("res://scenes/CarPolice90.tscn"),
	"sedan_90": preload("res://scenes/CarSedan90.tscn"),
	"sports_90": preload("res://scenes/CarSports90.tscn"),
	"wagon_90": preload("res://scenes/CarWagon90.tscn"),
	"suv_90": preload("res://scenes/CarSUV90.tscn"),
	"taxi_90": preload("res://scenes/CarTaxi90.tscn"),
	"atomic": preload("res://scenes/CarAtomic.tscn"),
	"compact": preload("res://scenes/CarCompact.tscn"),
	"convertible": preload("res://scenes/CarConvertible.tscn"),
	"coupe_modern": preload("res://scenes/CarCoupeModern.tscn"),
	"buggy": preload("res://scenes/CarBuggy.tscn"),
	"electric": preload("res://scenes/CarElectric.tscn"),
	"lowrider": preload("res://scenes/CarLowrider.tscn"),
	"microcar": preload("res://scenes/CarMicrocar.tscn"),
	"minivan": preload("res://scenes/CarMinivan.tscn"),
	"muscle": preload("res://scenes/CarMuscle.tscn"),
	"rally": preload("res://scenes/CarRally.tscn"),
	"wagon": preload("res://scenes/CarWagon.tscn"),
	"limo": preload("res://scenes/CarLimo.tscn"),
	"tuk_tuk": preload("res://scenes/CarTukTuk.tscn"),
	"classic": preload("res://scenes/CarClassic.tscn"),
	"hatchback": preload("res://scenes/CarHatchback.tscn"),
	"hover": preload("res://scenes/CarHover.tscn"),
	"police_modern": preload("res://scenes/CarPoliceModern.tscn"),
	"race_car": preload("res://scenes/CarRaceCar.tscn"),
	"sedan_modern": preload("res://scenes/CarSedanModern.tscn"),
	"sports_modern": preload("res://scenes/CarSportsModern.tscn"),
	"suv_modern": preload("res://scenes/CarSuvModern.tscn"),
	"taxi_modern": preload("res://scenes/CarTaxiModern.tscn"),
}
const PAINT_MENU_SCENE := preload("res://scenes/PaintMenu.tscn")
const ACCENT := Color(1.0, 0.78, 0.3)
const CAMERA_HOME := Vector3(4.6, 1.85, 5.8)
const CAMERA_FOV := 30.0
const INTRO_FOV := 38.0
const LOOK_TARGET := Vector3(0.0, 0.55, 0.0)
const SLIDE_DISTANCE := 6.5
const FRAME_REF_LENGTH := 4.4
const FRAME_REF_HEIGHT := 1.6
const FRAME_MAX_SCALE := 1.35
const PAINT_STAGE_SHIFT := -1.8
const FILL_LIGHT_ENERGY := 1.2
const PAINT_FILL_ENERGY := 2.6
const DRAG_SENSITIVITY := 0.012

@onready var _camera: Camera3D = $Camera3D
@onready var _stage: Node3D = $Stage
@onready var _car_name: Label = %CarName
@onready var _opponent_label: Label = %Opponent
@onready var _wallet_label: Label = %Wallet
@onready var _message_label: Label = %Message
@onready var _select_button: Button = %SelectButton
@onready var _paint_button: Button = %PaintButton
@onready var _prev_button: Button = %PrevButton
@onready var _next_button: Button = %NextButton
@onready var _back_button: Button = %BackButton
@onready var _fade: ColorRect = %Fade
@onready var _screen: Control = $UI/Screen
@onready var _fill_light: OmniLight3D = $FillLight

var _car: Node3D
var _car_id := ""
var _switching := true
var _time := 0.0
var _paint_menu: Control
var _paint_open := false
var _dragging := false
var _drag_yaw := 0.0


func _ready() -> void:
	_setup_environment()
	_aim_light($KeyLight, Vector3(0, 0.6, 0))
	_aim_light($RimLightLeft, Vector3(0, 0.7, -0.4))
	_aim_light($RimLightRight, Vector3(0, 0.7, -0.4))
	_aim_light($BackWash, Vector3(0, 2.0, -7.4))
	_camera.position = CAMERA_HOME
	_camera.fov = INTRO_FOV
	_camera.look_at(LOOK_TARGET)
	_style_buttons()
	AudioManager.connect_button_sfx(self)
	_paint_menu = PAINT_MENU_SCENE.instantiate()
	$UI.add_child(_paint_menu)
	_paint_menu.connect("closed", _on_paint_menu_closed)
	_show_car(RaceConfig.player_car)
	_car.position.x = SLIDE_DISTANCE

	_fade.visible = true
	_fade.modulate.a = 1.0
	var intro := create_tween()
	intro.set_parallel(true)
	intro.tween_property(_fade, "modulate:a", 0.0, 0.8)
	intro.tween_property(_camera, "fov", CAMERA_FOV, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro.tween_property(_car, "position:x", 0.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro.chain().tween_callback(_finish_intro)
	_select_button.grab_focus()


func _process(delta: float) -> void:
	_time += delta
	if _dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_end_drag()
	if not _switching and _car != null and not _dragging:
		_stage.rotation.y = _drag_yaw + sin(_time * 0.45) * 0.16


func _unhandled_input(event: InputEvent) -> void:
	if _switching or _paint_open:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not _dragging:
				_dragging = true
				_drag_yaw = _stage.rotation.y
				Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		elif _dragging:
			_end_drag()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _dragging:
		_drag_yaw += event.relative.x * DRAG_SENSITIVITY
		_stage.rotation.y = _drag_yaw
		get_viewport().set_input_as_handled()


func _end_drag() -> void:
	_dragging = false
	_drag_yaw = _stage.rotation.y
	_time = 0.0
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _input(event: InputEvent) -> void:
	if _paint_open:
		return
	if event.is_action_pressed("ui_left"):
		_cycle(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_cycle(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
		get_viewport().set_input_as_handled()


func _on_prev_button_pressed() -> void:
	_cycle(-1)


func _on_next_button_pressed() -> void:
	_cycle(1)


func _on_select_button_pressed() -> void:
	if _paint_open or _switching:
		return
	if not Garage.is_owned(_car_id):
		_buy_current_car()
		return
	_transition_to("res://scenes/CarTune.tscn")


func _buy_current_car() -> void:
	var price := Garage.car_price(_car_id)
	if Garage.buy_car(_car_id):
		RaceConfig.player_car = _car_id
		RaceConfig.pick_opponent()
		_opponent_label.text = _opponent_text()
		_message_label.text = tr("Auto acquistata! Ora puoi selezionarla e personalizzarla.")
		_message_label.add_theme_color_override("font_color", ACCENT)
		_update_purchase_ui()
		_select_button.grab_focus()
	else:
		_message_label.text = tr("CR$ insufficienti: servono %s.") % Garage.format_credits(price)
		_message_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.38))


func _on_paint_button_pressed() -> void:
	if _switching or _paint_open or not Garage.is_owned(_car_id):
		return
	_paint_open = true
	_set_nav_enabled(false)
	CarPaint.apply(_car, _car_id)
	_paint_menu.call("open", _car_id, RaceConfig.player_name(), _car)
	var slide := create_tween()
	slide.set_parallel(true)
	slide.tween_property(_stage, "position:x", PAINT_STAGE_SHIFT, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	slide.tween_property(_screen, "modulate:a", 0.0, 0.2)
	slide.tween_property(_fill_light, "light_energy", PAINT_FILL_ENERGY, 0.3)


func _on_paint_menu_closed() -> void:
	_paint_open = false
	_set_nav_enabled(true)
	_refresh_wallet()
	var slide := create_tween()
	slide.set_parallel(true)
	slide.tween_property(_stage, "position:x", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	slide.tween_property(_screen, "modulate:a", 1.0, 0.25)
	slide.tween_property(_fill_light, "light_energy", FILL_LIGHT_ENERGY, 0.3)
	_paint_button.grab_focus()


func _set_nav_enabled(enabled: bool) -> void:
	_select_button.disabled = not enabled
	_paint_button.disabled = not enabled or not Garage.is_owned(_car_id)
	_prev_button.disabled = not enabled
	_next_button.disabled = not enabled
	_back_button.disabled = not enabled


func _on_back_button_pressed() -> void:
	if _paint_open:
		return
	_transition_to("res://scenes/MainMenu.tscn")


func _finish_intro() -> void:
	_fade.visible = false
	_switching = false


func _show_car(car_id: String) -> void:
	_car = CAR_SCENES[car_id].instantiate()
	_stage.add_child(_car)
	_car_id = car_id
	_frame_camera(_car)
	_car_name.text = tr(String(RaceConfig.NAMES[car_id]))
	_message_label.text = ""
	_message_label.add_theme_color_override("font_color", Color(1.0, 0.62, 0.3))
	if Garage.is_owned(car_id):
		RaceConfig.player_car = car_id
		RaceConfig.pick_opponent()
	_opponent_label.text = _opponent_text()
	CarPaint.apply(_car, car_id)
	_update_purchase_ui()


func _opponent_text() -> String:
	var level := RaceConfig.duel_level(RaceConfig.player_car)
	if level <= 0:
		return tr("Avversario: %s") % tr(RaceConfig.opponent_name())
	return tr("Avversario: %s · Livello %d") % [tr(RaceConfig.opponent_name()), level]


func _refresh_wallet() -> void:
	_wallet_label.text = "%s   ·   %s" % [
		Garage.format_credits(Garage.credits), Garage.format_gold(Garage.gold)
	]


func _update_purchase_ui() -> void:
	_refresh_wallet()
	var owned := Garage.is_owned(_car_id)
	_paint_button.disabled = not owned
	if owned:
		_select_button.text = tr("Seleziona")
	else:
		_select_button.text = tr("Acquista · %s") % Garage.format_credits(Garage.car_price(_car_id))


func _frame_camera(car: Node3D) -> void:
	var bounds := _merge_aabb(car)
	var length := bounds.size.z
	var top := bounds.position.y + bounds.size.y
	var scale := clampf(
		maxf(length / FRAME_REF_LENGTH, top / FRAME_REF_HEIGHT), 1.0, FRAME_MAX_SCALE
	)
	_camera.position = CAMERA_HOME * scale
	_camera.look_at(LOOK_TARGET)


func _merge_aabb(node: Node) -> AABB:
	var merged := AABB()
	var found := false
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		if current is MeshInstance3D:
			var mesh := current as MeshInstance3D
			var relative := Transform3D.IDENTITY
			var parent := mesh.get_parent()
			while parent != null and parent != node:
				if parent is Node3D:
					relative = (parent as Node3D).transform * relative
				parent = parent.get_parent()
			var box: AABB = relative * mesh.get_aabb()
			merged = box if not found else merged.merge(box)
			found = true
		for child in current.get_children():
			stack.append(child)
	return merged


func _cycle(direction: int) -> void:
	if _switching or _paint_open:
		return
	var index := CAR_IDS.find(_car_id)
	var next := CAR_IDS[(index + direction + CAR_IDS.size()) % CAR_IDS.size()]
	_switch_to(next, direction)


func _switch_to(car_id: String, direction: int) -> void:
	_switching = true
	_end_drag()
	_drag_yaw = 0.0
	_stage.rotation.y = 0.0
	_stage.position.x = 0.0
	var out := create_tween()
	out.tween_property(_car, "position:x", -SLIDE_DISTANCE * direction, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await out.finished

	_car.queue_free()
	_show_car(car_id)
	_car.position.x = SLIDE_DISTANCE * direction
	_car_name.modulate.a = 0.0
	_opponent_label.modulate.a = 0.0
	_camera.fov = CAMERA_FOV + 4.0

	var enter := create_tween()
	enter.set_parallel(true)
	enter.tween_property(_car, "position:x", 0.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	enter.tween_property(_camera, "fov", CAMERA_FOV, 0.45)
	enter.tween_property(_car_name, "modulate:a", 1.0, 0.3)
	enter.tween_property(_opponent_label, "modulate:a", 1.0, 0.3)
	await enter.finished

	_switching = false
	_select_button.grab_focus()


func _transition_to(path: String) -> void:
	if _switching:
		return
	_switching = true
	_end_drag()
	_fade.visible = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	_fade.modulate.a = 0.0
	var fade_out := create_tween()
	fade_out.tween_property(_fade, "modulate:a", 1.0, 0.35)
	await fade_out.finished
	get_tree().change_scene_to_file(path)


func _setup_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.006, 0.007, 0.01)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.35, 0.4, 0.5)
	environment.ambient_light_energy = 0.4
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 0.35
	environment.glow_bloom = 0.02
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.03, 0.035, 0.05)
	environment.fog_light_energy = 0.4
	environment.fog_density = 0.012
	$WorldEnvironment.environment = environment


func _aim_light(light: Node3D, target: Vector3) -> void:
	light.look_at(target)


func _style_buttons() -> void:
	var flat := StyleBoxEmpty.new()
	for button in [_prev_button, _next_button, _back_button]:
		for state in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
			button.add_theme_stylebox_override(state, flat)

	for arrow in [_prev_button, _next_button]:
		arrow.add_theme_color_override("font_color", Color(0.82, 0.85, 0.9))
		arrow.add_theme_color_override("font_hover_color", ACCENT)
		arrow.add_theme_color_override("font_pressed_color", ACCENT)

	_back_button.add_theme_font_size_override("font_size", 15)
	_back_button.add_theme_color_override("font_color", Color(0.55, 0.6, 0.7))
	_back_button.add_theme_color_override("font_hover_color", Color(0.95, 0.95, 0.95))
	_back_button.add_theme_color_override("font_pressed_color", Color(0.95, 0.95, 0.95))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.14, 0.115, 0.06)
	normal.border_color = ACCENT
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(12)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.21, 0.17, 0.08)

	for state in ["normal", "focus"]:
		_select_button.add_theme_stylebox_override(state, normal)
	for state in ["hover", "pressed", "hover_pressed"]:
		_select_button.add_theme_stylebox_override(state, hover)
	_select_button.add_theme_stylebox_override("disabled", normal)

	_select_button.add_theme_font_size_override("font_size", 22)
	_select_button.add_theme_color_override("font_color", ACCENT)
	_select_button.add_theme_color_override("font_hover_color", Color(1, 0.9, 0.65))
	_select_button.add_theme_color_override("font_pressed_color", Color(1, 0.9, 0.65))
	_select_button.add_theme_color_override("font_disabled_color", Color(0.62, 0.5, 0.26))

	var paint_normal := StyleBoxFlat.new()
	paint_normal.bg_color = Color(0.1, 0.11, 0.14)
	paint_normal.border_color = Color(1, 1, 1, 0.18)
	paint_normal.set_border_width_all(1)
	paint_normal.set_corner_radius_all(10)

	var paint_hover := paint_normal.duplicate() as StyleBoxFlat
	paint_hover.bg_color = Color(0.16, 0.17, 0.21)
	paint_hover.border_color = ACCENT

	for state in ["normal", "focus"]:
		_paint_button.add_theme_stylebox_override(state, paint_normal)
	for state in ["hover", "pressed", "hover_pressed"]:
		_paint_button.add_theme_stylebox_override(state, paint_hover)
	_paint_button.add_theme_stylebox_override("disabled", paint_normal)

	_paint_button.add_theme_font_size_override("font_size", 16)
	_paint_button.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	_paint_button.add_theme_color_override("font_hover_color", Color(1, 0.9, 0.65))
	_paint_button.add_theme_color_override("font_pressed_color", Color(1, 0.9, 0.65))
	_paint_button.add_theme_color_override("font_disabled_color", Color(0.5, 0.53, 0.6))
