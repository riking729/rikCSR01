extends RefCounted

const SKY_SHADER := preload("res://shaders/beach_sky.gdshader")
const ICE_SHADER := preload("res://shaders/ice_road.gdshader")

const ENVIRONMENTS: Array[String] = [
	"city",
	"beach_day",
	"beach_night",
	"jungle_day",
	"jungle_night",
	"mountain_ice",
]
const ENVIRONMENT_LABELS: Array[String] = [
	"Città",
	"Spiaggia · Giorno",
	"Spiaggia · Notte",
	"Giungla · Giorno",
	"Giungla · Notte",
	"Montagna · Ghiaccio",
]

const DAY_SUN_DIR := Vector3(-0.55, 0.62, -0.62)
const NIGHT_MOON_DIR := Vector3(-0.5, 0.235, -0.72)
const JUNGLE_MOON_DIR := Vector3(-0.576, 0.11, -0.81)
const JUNGLE_SUN_DIR := Vector3(-0.45, 0.7, -0.55)
const MOUNTAIN_SUN_DIR := Vector3(-0.35, 0.5, -0.8)
const MOUNTAIN_TILT_DEG := 6.0
const JUNGLE_MOON_SIZE := 0.9990


static func is_beach(preset: String) -> bool:
	return preset == "beach_day" or preset == "beach_night"


static func is_jungle(preset: String) -> bool:
	return preset == "jungle_day" or preset == "jungle_night"


static func is_mountain(preset: String) -> bool:
	return preset == "mountain_ice"


static func is_night(preset: String) -> bool:
	return preset == "city" or preset == "beach_night" or preset == "jungle_night"


static func mountain_tilt() -> float:
	return deg_to_rad(MOUNTAIN_TILT_DEG)


static func apply(game: Node3D, preset: String) -> void:
	var beach := game.get_node_or_null("Beach")
	var jungle := game.get_node_or_null("Jungle")
	var mountain := game.get_node_or_null("Mountain")
	var city := game.get_node_or_null("City")
	var world := game.get_node_or_null("WorldEnvironment") as WorldEnvironment
	var sun := game.get_node_or_null("Sun") as DirectionalLight3D
	var road := game.get_node_or_null("Road") as Node3D
	var road_mesh := game.get_node_or_null("Road/Mesh") as MeshInstance3D
	if world == null or sun == null:
		return

	var beach_on := is_beach(preset)
	var jungle_on := is_jungle(preset)
	var mountain_on := is_mountain(preset)

	if beach != null:
		beach.visible = beach_on
		if beach_on:
			beach.call("configure", preset == "beach_night")
	if jungle != null:
		jungle.visible = jungle_on
		if jungle_on:
			jungle.call("configure", preset == "jungle_night")
	if mountain != null:
		mountain.visible = mountain_on
	if city != null:
		city.visible = preset == "city"

	if beach_on:
		world.environment = _beach_environment(preset == "beach_night")
		_apply_beach_sun(sun, preset == "beach_night")
	elif jungle_on:
		world.environment = _jungle_environment(preset == "jungle_night")
		_apply_jungle_sun(sun, preset == "jungle_night")
	elif mountain_on:
		world.environment = _mountain_environment()
		_apply_mountain_sun(sun)
	else:
		world.environment = _city_environment()
		_apply_city_sun(sun)

	_swap_road_material(road_mesh, preset)
	_apply_road_tilt(road, preset)


static func _city_environment() -> Environment:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.11, 0.11, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.6, 0.62)
	env.ambient_light_energy = 0.8
	return env


static func _beach_environment(night: bool) -> Environment:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = SKY_SHADER
	sky_material.set_shader_parameter("night", night)
	sky_material.set_shader_parameter("moon_dir", NIGHT_MOON_DIR.normalized())
	sky.sky_material = sky_material
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.5 if night else 1.0
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	env.glow_enabled = true
	env.glow_intensity = 0.55 if night else 0.2
	env.glow_bloom = 0.08 if night else 0.03
	env.glow_hdr_threshold = 0.9 if night else 1.1

	env.fog_enabled = true
	env.fog_light_color = Color(0.07, 0.1, 0.2) if night else Color(0.72, 0.84, 0.95)
	env.fog_light_energy = 0.6
	env.fog_density = 0.0012 if night else 0.0008
	env.fog_sky_affect = 0.15
	return env


static func _jungle_environment(night: bool) -> Environment:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = SKY_SHADER
	sky_material.set_shader_parameter("night", night)
	sky_material.set_shader_parameter("moon_dir", JUNGLE_MOON_DIR.normalized())
	sky_material.set_shader_parameter("moon_size", JUNGLE_MOON_SIZE)
	sky_material.set_shader_parameter("moon_brightness", 3.4)
	sky_material.set_shader_parameter("moon_halo", 2.4)
	sky_material.set_shader_parameter("day_top", Color(0.1, 0.28, 0.4))
	sky_material.set_shader_parameter("day_horizon", Color(0.5, 0.66, 0.58))
	sky_material.set_shader_parameter("night_top", Color(0.008, 0.02, 0.045))
	sky_material.set_shader_parameter("night_horizon", Color(0.035, 0.09, 0.11))
	sky.sky_material = sky_material
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.6 if night else 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	env.glow_enabled = true
	env.glow_intensity = 0.55 if night else 0.12
	env.glow_bloom = 0.06 if night else 0.02
	env.glow_hdr_threshold = 0.9 if night else 1.1

	env.fog_enabled = true
	env.fog_light_color = Color(0.03, 0.06, 0.07) if night else Color(0.3, 0.44, 0.34)
	env.fog_light_energy = 0.6
	env.fog_density = 0.0026 if night else 0.0015
	env.fog_sky_affect = 0.12
	return env


static func _mountain_environment() -> Environment:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = SKY_SHADER
	sky_material.set_shader_parameter("night", false)
	sky_material.set_shader_parameter("day_top", Color(0.07, 0.2, 0.5))
	sky_material.set_shader_parameter("day_horizon", Color(0.6, 0.76, 0.93))
	sky.sky_material = sky_material
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	env.glow_enabled = true
	env.glow_intensity = 0.18
	env.glow_bloom = 0.02
	env.glow_hdr_threshold = 1.1

	env.fog_enabled = true
	env.fog_light_color = Color(0.78, 0.87, 0.97)
	env.fog_light_energy = 0.55
	env.fog_density = 0.001
	env.fog_sky_affect = 0.1
	return env


static func _apply_city_sun(sun: DirectionalLight3D) -> void:
	sun.rotation_degrees = Vector3(-45.0, -30.0, 0.0)
	sun.light_color = Color(1.0, 1.0, 1.0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true


static func _apply_beach_sun(sun: DirectionalLight3D, night: bool) -> void:
	var direction: Vector3 = (NIGHT_MOON_DIR if night else DAY_SUN_DIR).normalized()
	sun.look_at(sun.global_position - direction)
	sun.light_color = Color(0.62, 0.72, 1.0) if night else Color(1.0, 0.96, 0.88)
	sun.light_energy = 0.45 if night else 1.35
	sun.shadow_enabled = true


static func _apply_jungle_sun(sun: DirectionalLight3D, night: bool) -> void:
	var direction: Vector3 = (JUNGLE_MOON_DIR if night else JUNGLE_SUN_DIR).normalized()
	sun.look_at(sun.global_position - direction)
	sun.light_color = Color(0.6, 0.72, 1.0) if night else Color(1.0, 0.95, 0.78)
	sun.light_energy = 0.8 if night else 1.6
	sun.shadow_enabled = true


static func _apply_mountain_sun(sun: DirectionalLight3D) -> void:
	var direction := MOUNTAIN_SUN_DIR.normalized()
	sun.look_at(sun.global_position - direction)
	sun.light_color = Color(1.0, 0.98, 0.93)
	sun.light_energy = 1.35
	sun.shadow_enabled = true


static func _swap_road_material(road_mesh: MeshInstance3D, preset: String) -> void:
	if road_mesh == null:
		return
	if not road_mesh.has_meta("city_material"):
		road_mesh.set_meta("city_material", road_mesh.get_surface_override_material(0))

	if is_beach(preset):
		if not road_mesh.has_meta("beach_material"):
			var sand := StandardMaterial3D.new()
			sand.albedo_color = Color(0.74, 0.6, 0.33)
			sand.roughness = 0.98
			road_mesh.set_meta("beach_material", sand)
		road_mesh.set_surface_override_material(0, road_mesh.get_meta("beach_material"))
	elif is_jungle(preset):
		if not road_mesh.has_meta("jungle_material"):
			var wet := StandardMaterial3D.new()
			wet.albedo_color = Color(0.1, 0.11, 0.1)
			wet.roughness = 0.5
			road_mesh.set_meta("jungle_material", wet)
		road_mesh.set_surface_override_material(0, road_mesh.get_meta("jungle_material"))
	elif is_mountain(preset):
		if not road_mesh.has_meta("ice_material"):
			var ice := ShaderMaterial.new()
			ice.shader = ICE_SHADER
			road_mesh.set_meta("ice_material", ice)
		road_mesh.set_surface_override_material(0, road_mesh.get_meta("ice_material"))
	else:
		road_mesh.set_surface_override_material(0, road_mesh.get_meta("city_material"))


static func _apply_road_tilt(road: Node3D, preset: String) -> void:
	if road == null:
		return
	if not road.has_meta("flat_rotation"):
		road.set_meta("flat_rotation", road.rotation)
	var flat: Vector3 = road.get_meta("flat_rotation")
	if is_mountain(preset):
		road.rotation = Vector3(flat.x, flat.y, flat.z + mountain_tilt())
	else:
		road.rotation = flat
