extends Node3D

const GEAR_MAX_SPEED: Array[float] = [12.0, 20.0, 28.0, 36.0, 44.0, 52.0]
const GEAR_ACCEL: Array[float] = [9.0, 7.0, 5.5, 4.3, 3.4, 2.6]
const BRAKE_DECEL := 14.0
const ROLL_DECEL := 1.2
const CAMERA_OFFSET := Vector3(5.15, 2.2, 4.6)
const AI_REACTION := 0.4
const AI_SHIFT_RATIO := 0.75
const AI_PACE_ACCEL := 1.5
const NITRO_DRAIN := 30.0
const NITRO_BOOST_RATIO := 1.15
const NITRO_BOOST_ACCEL := 2.4
const NITRO_FADE := 6.0
const FINISH_Z := 185.0
const FINISH_DECEL := 75.0
const MAX_CAR_Z := 218.0
const INACTIVITY_LIMIT := 4.0
const INACTIVITY_MIN_PROGRESS := 0.8
const INTRO_DURATION := 5.2
const INTRO_SHOTS := [
	{"time": 0.0, "position": Vector3(-7.6, 1.15, 5.8), "look": Vector3(-1.2, 0.75, 0.2)},
	{"time": 1.8, "position": Vector3(7.8, 2.7, 4.6), "look": Vector3(0.0, 0.85, 0.4)},
	{"time": 3.6, "position": Vector3(0.0, 5.0, -11.0), "look": Vector3(0.0, 0.6, 1.8)},
	{"time": 5.2, "position": Vector3(3.2, 2.2, 4.6), "look": Vector3(-0.6, 0.8, 0.8)},
]
const ENV_PRESETS := preload("res://scripts/environment_presets.gd")
const CAR_LIGHTS := preload("res://scripts/car_lights.gd")
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

var speed := 0.0
var gear := 0
var ai_speed := 0.0
var ai_gear := 0
var nitro_amount := 100.0
var boosting := false
var race_started := false
var race_finished := false
var intro_playing := false
var player_time := -1.0
var ai_time := -1.0

var _ai_reaction := AI_REACTION
var _ai_shift_ratio := AI_SHIFT_RATIO
var _prestart_revs := 0.0
var _race_time := 0.0
var _idle_time := 0.0
var _last_progress := 0.0
var _intro_time := 0.0
var _player_name := ""
var _ai_name := ""
var _player_speed_mult := 1.0
var _player_accel_mult := 1.0
var _player_nos_drain_mult := 1.0
var _ai_speed_mult := 1.0
var _ai_accel_mult := 1.0
var _sand_trails: Array[CPUParticles3D] = []
var _environment := ""

var car: Node3D
var ai_car: Node3D

@onready var camera: Camera3D = $Camera3D
@onready var intro_camera: Camera3D = $IntroCamera
@onready var engine_audio: Node = $EngineAudio
@onready var dashboard: Control = %Dashboard
@onready var countdown_label: Label = %Countdown
@onready var race_timer_label: Label = %RaceTimer
@onready var results: Control = %RaceResults
@onready var intro_root: Control = %Intro
@onready var intro_content: Control = %Content
@onready var intro_level: Label = %Level
@onready var intro_player: Label = %PlayerName
@onready var intro_opponent: Label = %OpponentName
@onready var intro_fade: ColorRect = %Fade


func _ready() -> void:
	_environment = RaceConfig.roll_environment()
	ENV_PRESETS.apply(self, _environment)
	_spawn_cars()
	engine_audio.configure(RaceConfig.player_car)
	_update_hud()
	_update_race_timer()
	results.connect("advance_pressed", _on_results_advance)
	results.connect("menu_pressed", _on_results_menu)
	countdown_label.visible = false
	_play_intro()


func _play_intro() -> void:
	intro_playing = true
	_intro_time = 0.0
	dashboard.visible = false
	race_timer_label.visible = false
	countdown_label.visible = false
	intro_root.visible = true
	intro_content.visible = true
	intro_content.modulate.a = 0.0
	intro_fade.color.a = 0.0
	intro_player.text = _player_name
	intro_opponent.text = _ai_name
	intro_level.text = RaceConfig.duel_label(RaceConfig.player_car)
	_update_intro_camera()
	intro_camera.make_current()

	await get_tree().create_timer(INTRO_DURATION).timeout

	var black := create_tween()
	black.tween_property(intro_fade, "color:a", 1.0, 0.22)
	await black.finished

	intro_content.visible = false
	camera.make_current()
	dashboard.visible = true
	race_timer_label.visible = true
	intro_playing = false

	var reveal := create_tween()
	reveal.tween_property(intro_fade, "color:a", 0.0, 0.28)
	await reveal.finished
	intro_root.visible = false
	_start_countdown()


func _process(delta: float) -> void:
	if not intro_playing:
		return
	_intro_time += delta
	_update_intro_camera()
	var fade_in := clampf(_intro_time / 0.5, 0.0, 1.0)
	var fade_out := clampf((INTRO_DURATION - _intro_time) / 0.7, 0.0, 1.0)
	intro_content.modulate.a = minf(fade_in, fade_out)


func _update_intro_camera() -> void:
	var first: Dictionary = INTRO_SHOTS[0]
	if _intro_time <= float(first["time"]):
		_set_intro_camera(first["position"], first["look"])
		return

	var prev: Dictionary = first
	for i in range(1, INTRO_SHOTS.size()):
		var next: Dictionary = INTRO_SHOTS[i]
		if _intro_time <= float(next["time"]):
			var from_time := float(prev["time"])
			var span := maxf(float(next["time"]) - from_time, 0.001)
			var t := clampf((_intro_time - from_time) / span, 0.0, 1.0)
			t = t * t * (3.0 - 2.0 * t)
			var from_pos: Vector3 = prev["position"]
			var to_pos: Vector3 = next["position"]
			var from_look: Vector3 = prev["look"]
			var to_look: Vector3 = next["look"]
			intro_camera.global_position = from_pos.lerp(to_pos, t)
			intro_camera.look_at(from_look.lerp(to_look, t))
			return
		prev = next

	var last: Dictionary = INTRO_SHOTS[INTRO_SHOTS.size() - 1]
	_set_intro_camera(last["position"], last["look"])


func _set_intro_camera(cam_position: Vector3, look: Vector3) -> void:
	intro_camera.global_position = cam_position
	intro_camera.look_at(look)


func _spawn_cars() -> void:
	if not Garage.is_owned(RaceConfig.player_car):
		RaceConfig.player_car = "coupe"
	var player_scene: PackedScene = CAR_SCENES[RaceConfig.player_car]
	var opponent_id := RaceConfig.opponent_car()
	var opponent_scene: PackedScene = CAR_SCENES[opponent_id]
	_player_name = tr(RaceConfig.player_name())
	_ai_name = tr(String(RaceConfig.NAMES[opponent_id]))

	_player_speed_mult = Garage.performance(RaceConfig.player_car, "top_speed")
	_player_accel_mult = Garage.performance(RaceConfig.player_car, "transmission")
	_player_nos_drain_mult = 1.0 / Garage.performance(RaceConfig.player_car, "nos")

	var ai_multiplier := Settings.ai_multiplier()
	if Series.is_active():
		ai_multiplier *= 1.0 + Series.active_difficulty()
	# Usa i dati della vettura migliore: la difficolta' resta uguale con qualsiasi auto scegli.
	var ai_base_speed := Garage.best_base_performance("top_speed")
	var ai_base_accel := Garage.best_base_performance("transmission")
	_ai_speed_mult = ai_base_speed * ai_multiplier
	_ai_accel_mult = ai_base_accel * ai_multiplier * AI_PACE_ACCEL

	car = player_scene.instantiate() as Node3D
	car.name = "Car"
	car.position = Vector3(-1.95, 0.0, 0.0)
	add_child(car)
	CarPaint.apply(car, RaceConfig.player_car)

	ai_car = opponent_scene.instantiate() as Node3D
	ai_car.name = "Car2"
	ai_car.position = Vector3(1.95, 0.0, 0.0)
	add_child(ai_car)
	CarPaint.apply(ai_car, opponent_id)

	var night_lights := ENV_PRESETS.is_night(_environment)
	CAR_LIGHTS.attach(car, night_lights)
	CAR_LIGHTS.attach(ai_car, night_lights)

	if ENV_PRESETS.is_beach(_environment):
		_sand_trails.append(_attach_sand_trail(car))
		_sand_trails.append(_attach_sand_trail(ai_car))
	if ENV_PRESETS.is_mountain(_environment):
		_tilt_car_to_slope(car)
		_tilt_car_to_slope(ai_car)


func _tilt_car_to_slope(vehicle: Node3D) -> void:
	var tilt: float = ENV_PRESETS.mountain_tilt()
	vehicle.rotation.z = tilt
	vehicle.position.y = vehicle.position.x * sin(tilt)


func _attach_sand_trail(target: Node3D) -> CPUParticles3D:
	var trail := CPUParticles3D.new()
	trail.amount = 72
	trail.lifetime = 1.2
	trail.emitting = false
	trail.local_coords = false
	trail.direction = Vector3(0.0, 0.35, -1.0)
	trail.spread = 26.0
	trail.initial_velocity_min = 2.5
	trail.initial_velocity_max = 6.5
	trail.gravity = Vector3(0.0, -1.6, 0.0)
	trail.scale_amount_min = 0.08
	trail.scale_amount_max = 0.22

	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([
		Color(1.0, 0.94, 0.7, 0.0),
		Color(1.0, 0.88, 0.55, 0.6),
		Color(1.0, 0.84, 0.5, 0.0),
	])
	trail.color_ramp = ramp

	var puff := GradientTexture2D.new()
	puff.width = 64
	puff.height = 64
	puff.fill = GradientTexture2D.FILL_RADIAL
	puff.fill_from = Vector2(0.5, 0.5)
	puff.fill_to = Vector2(0.95, 0.5)
	var puff_gradient := Gradient.new()
	puff_gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	puff_gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	puff.gradient = puff_gradient

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.albedo_texture = puff
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.2, 0.2)
	mesh.material = material
	trail.mesh = mesh

	trail.position = Vector3(0.0, 0.3, -1.8)
	target.add_child(trail)
	return trail


func _update_sand_trails() -> void:
	if _sand_trails.is_empty():
		return
	_sand_trails[0].emitting = speed > 4.0
	_sand_trails[1].emitting = ai_speed > 4.0


func _start_countdown() -> void:
	countdown_label.visible = true
	for number in [3, 2, 1]:
		countdown_label.text = str(number)
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = tr("VIA!")
	race_started = true
	await get_tree().create_timer(0.8).timeout
	countdown_label.visible = false


func _physics_process(delta: float) -> void:
	if intro_playing:
		return
	if not race_started:
		_rev_before_start(delta)
		return
	if race_finished:
		return

	var prev_player_z := car.position.z
	var prev_ai_z := ai_car.position.z

	_drive_player(delta)
	_drive_ai(delta)
	_race_time += delta

	if player_time < 0.0:
		var player_cross := _cross_fraction(prev_player_z, car.position.z)
		if player_cross >= 0.0:
			player_time = _race_time - delta + delta * player_cross
	if ai_time < 0.0:
		var ai_cross := _cross_fraction(prev_ai_z, ai_car.position.z)
		if ai_cross >= 0.0:
			ai_time = _race_time - delta + delta * ai_cross

	camera.global_position = car.global_position + CAMERA_OFFSET
	_update_hud()
	_update_sand_trails()

	_prestart_revs = move_toward(_prestart_revs, 0.0, delta * 1.4)
	var max_speed: float = GEAR_MAX_SPEED[gear]
	var throttle := 0.0 if player_time >= 0.0 else Input.get_action_strength("accelerate")
	engine_audio.update_engine(
		maxf(clampf(speed / max_speed, 0.0, 1.0), _prestart_revs),
		throttle
	)

	if player_time >= 0.0 and ai_time >= 0.0:
		_finish_race()
	else:
		_track_inactivity(delta)


func _track_inactivity(delta: float) -> void:
	var lead := maxf(car.position.z, ai_car.position.z)
	if lead > _last_progress + INACTIVITY_MIN_PROGRESS:
		_last_progress = lead
		_idle_time = 0.0
		return
	_idle_time += delta
	if _idle_time >= INACTIVITY_LIMIT:
		_finish_race()


func _rev_before_start(delta: float) -> void:
	var throttle := Input.get_action_strength("accelerate")
	_prestart_revs = lerpf(_prestart_revs, throttle, clampf(delta * 8.0, 0.0, 1.0))
	engine_audio.update_engine(_prestart_revs, throttle)
	dashboard.update_state(
		0.0, _prestart_revs, nitro_amount, gear + 1, GEAR_MAX_SPEED.size(), false
	)


func _drive_player(delta: float) -> void:
	if player_time >= 0.0:
		speed = maxf(speed - FINISH_DECEL * delta, 0.0)
		_move_car(car, speed * delta)
		return

	var throttle := Input.get_action_strength("accelerate")
	var brake := Input.get_action_strength("brake")
	var max_speed: float = GEAR_MAX_SPEED[gear] * _player_speed_mult

	boosting = Input.is_action_pressed("nitro") and nitro_amount > 0.0 and throttle > 0.0
	var effective_max := max_speed
	var accel_mult := 1.0
	if boosting:
		nitro_amount = max(nitro_amount - NITRO_DRAIN * _player_nos_drain_mult * delta, 0.0)
		effective_max = max_speed * NITRO_BOOST_RATIO
		accel_mult = NITRO_BOOST_ACCEL

	if throttle > 0.0 and speed < effective_max:
		var accel: float = (
			GEAR_ACCEL[gear] * throttle * accel_mult * _player_accel_mult * (1.0 - speed / effective_max)
		)
		speed = min(speed + accel * delta, effective_max)
	if not boosting and speed > max_speed:
		speed = max(speed - NITRO_FADE * delta, max_speed)
	if brake > 0.0:
		speed = max(speed - BRAKE_DECEL * brake * delta, 0.0)
	if throttle == 0.0 and brake == 0.0:
		speed = max(speed - ROLL_DECEL * delta, 0.0)

	_move_car(car, speed * delta)


func _drive_ai(delta: float) -> void:
	if ai_time >= 0.0:
		ai_speed = maxf(ai_speed - FINISH_DECEL * delta, 0.0)
		_move_car(ai_car, ai_speed * delta)
		return

	_ai_reaction = max(_ai_reaction - delta, 0.0)
	if _ai_reaction > 0.0:
		return

	var max_speed: float = GEAR_MAX_SPEED[ai_gear] * _ai_speed_mult
	if ai_speed < max_speed:
		var accel: float = GEAR_ACCEL[ai_gear] * (1.0 - ai_speed / max_speed) * _ai_accel_mult
		ai_speed = min(ai_speed + accel * delta, max_speed)
	if ai_gear < GEAR_MAX_SPEED.size() - 1 and ai_speed >= max_speed * _ai_shift_ratio:
		ai_gear += 1

	_move_car(ai_car, ai_speed * delta)


func _move_car(target: Node3D, distance: float) -> void:
	target.position.z = minf(target.position.z + distance, MAX_CAR_Z)
	if target.has_method("spin_wheels"):
		target.call("spin_wheels", distance)


func _cross_fraction(prev_z: float, z: float) -> float:
	if prev_z >= FINISH_Z or z < FINISH_Z or z <= prev_z:
		return -1.0
	return clampf((FINISH_Z - prev_z) / (z - prev_z), 0.0, 1.0)


func _finish_race() -> void:
	if race_finished:
		return
	race_finished = true
	engine_audio.update_engine(0.0, 0.0)
	for trail in _sand_trails:
		trail.emitting = false
	_update_race_timer()

	var player_won: bool
	if player_time >= 0.0 and ai_time >= 0.0:
		player_won = player_time <= ai_time
	elif player_time >= 0.0:
		player_won = true
	elif ai_time >= 0.0:
		player_won = false
	else:
		player_won = car.position.z >= ai_car.position.z

	if Series.is_active():
		var context := tr("%s · Gara %d/%d") % [
			tr(Series.active_name()), Series.active_race + 1, Series.active_race_count()
		]
		var prize := Series.active_prize() if player_won else Garage.LOSE_REWARD
		Garage.add_credits(prize)
		var gold_prize := Series.active_gold_prize() if player_won else Garage.LOSE_GOLD
		Garage.add_gold(gold_prize)
		var advance_label := "Riprova"
		var show_menu := true
		if player_won:
			Series.advance()
			if Series.has_next():
				advance_label = "Prossima gara"
			else:
				advance_label = "Torna al menu"
				show_menu = false
		results.call(
			"show_results", player_time, ai_time, _player_name, _ai_name,
			prize, context, advance_label, show_menu, player_won, gold_prize
		)
	else:
		var prize := Garage.award_race(player_won)
		var gold_prize := Garage.award_gold(player_won)
		results.call(
			"show_results", player_time, ai_time, _player_name, _ai_name,
			prize, "", "Avanti", false, player_won, gold_prize
		)


func _on_results_advance() -> void:
	if Series.is_active() and Series.has_next():
		get_tree().change_scene_to_file("res://scenes/CarTune.tscn")
	else:
		Series.clear_active()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_results_menu() -> void:
	Series.clear_active()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if intro_playing:
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		Series.clear_active()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	elif event.is_action_pressed("shift_gear") and race_started and not race_finished:
		var next_gear: int = mini(gear + 1, GEAR_MAX_SPEED.size() - 1)
		if next_gear != gear:
			gear = next_gear
			engine_audio.play_shift()
			_update_hud()


func _update_hud() -> void:
	var max_speed: float = GEAR_MAX_SPEED[gear] * _player_speed_mult
	var revs := clampf(speed / max_speed, 0.0, 1.0)
	dashboard.update_state(speed * 3.6, revs, nitro_amount, gear + 1, GEAR_MAX_SPEED.size(), race_started)
	_update_race_timer()


func _update_race_timer() -> void:
	var elapsed := player_time if player_time >= 0.0 else _race_time
	race_timer_label.text = ("%.2f s" % maxf(elapsed, 0.0)).replace(".", ",")
