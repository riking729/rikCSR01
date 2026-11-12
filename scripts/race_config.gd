extends Node

const ENV_PRESETS := preload("res://scripts/environment_presets.gd")

const CARS: Array[String] = [
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

const NAMES := {
	"coupe": "Coupé",
	"sports": "Sportiva GT",
	"sedan": "Berlina",
	"city": "City Car",
	"police": "Auto della Polizia",
	"taxi": "Taxi",
	"suv": "SUV",
	"sedan_50": "Berlina anni '50",
	"wagon_50": "Station Wagon anni '50",
	"pickup_50": "Pickup anni '50",
	"roadster_50": "Roadster anni '50",
	"convertible_60": "Cabriolet anni '60",
	"compact_60": "Utilitaria anni '60",
	"microbus_60": "Microbus anni '60",
	"sports_60": "Sportiva anni '60",
	"coupe_70": "Coupé anni '70",
	"hatchback_70": "Hatchback anni '70",
	"pickup_70": "Pickup anni '70",
	"sedan_70": "Berlina anni '70",
	"hatchback_80": "Hatchback anni '80",
	"sedan_80": "Berlina anni '80",
	"sports_80": "Sportiva anni '80",
	"wagon_80": "Station Wagon anni '80",
	"van_80": "Furgone anni '80",
	"compact_90": "Compatta anni '90",
	"van_90": "Furgone anni '90",
	"hatchback_90": "Hatchback anni '90",
	"minivan_90": "Monovolume anni '90",
	"offroad_90": "Fuoristrada anni '90",
	"pickup_90": "Pickup anni '90",
	"police_90": "Volante anni '90",
	"sedan_90": "Berlina anni '90",
	"sports_90": "Sportiva anni '90",
	"wagon_90": "Station Wagon anni '90",
	"suv_90": "SUV anni '90",
	"taxi_90": "Taxi anni '90",
	"atomic": "Atomic Age",
	"compact": "Compatta",
	"convertible": "Cabriolet",
	"coupe_modern": "Coupé Moderna",
	"buggy": "Dune Buggy",
	"electric": "Elettrica",
	"lowrider": "Lowrider",
	"microcar": "Microcar",
	"minivan": "Monovolume",
	"muscle": "Muscle Car",
	"rally": "Rally",
	"wagon": "Station Wagon",
	"limo": "Limousine",
	"tuk_tuk": "Tuk Tuk",
	"classic": "Classica",
	"hatchback": "Hatchback",
	"hover": "Hover Car",
	"police_modern": "Intercettore",
	"race_car": "Formula Corsa",
	"sedan_modern": "Berlina Moderna",
	"sports_modern": "Sportiva Moderna",
	"suv_modern": "SUV Moderno",
	"taxi_modern": "Taxi Moderno",
}

var player_car := "coupe"
var opponent_car_id := ""
var race_environment := ""
var _last_environment := ""
var _environment_streak := 0
var _last_opponent_id := ""

# Coppie fisse di sfidanti per livello, ordinate per prestazioni crescenti.
const DUELS := [
	{"name": "Classiche", "cars": ["sedan_50", "wagon_50"]},
	{"name": "Utilitarie", "cars": ["compact_60", "microbus_60"]},
	{"name": "Pickup", "cars": ["pickup_50", "pickup_70"]},
	{"name": "Città", "cars": ["city", "taxi"]},
	{"name": "Scoperte", "cars": ["roadster_50", "convertible_60"]},
	{"name": "Hatchback", "cars": ["hatchback_70", "hatchback_80"]},
	{"name": "Familiari", "cars": ["sedan", "suv"]},
	{"name": "Berline", "cars": ["sedan_70", "sedan_80"]},
	{"name": "Coupé sportive", "cars": ["sports_60", "coupe_70"]},
	{"name": "Stradali", "cars": ["coupe", "police"]},
	{"name": "Sportive", "cars": ["sports", "sports_80"]},
	{"name": "Familiari anni '80", "cars": ["wagon_80", "van_80"]},
	{"name": "Compatta e taxi", "cars": ["compact_90", "taxi_90"]},
	{"name": "Furgoni anni '90", "cars": ["hatchback_90", "van_90"]},
	{"name": "Monovolume e berlina", "cars": ["minivan_90", "sedan_90"]},
	{"name": "Wagon e pickup", "cars": ["wagon_90", "pickup_90"]},
	{"name": "Tutto-terreno", "cars": ["suv_90", "offroad_90"]},
	{"name": "Piccole", "cars": ["tuk_tuk", "microcar"]},
	{"name": "Compatte moderne", "cars": ["compact", "hatchback"]},
	{"name": "Coupé e cabrio", "cars": ["convertible", "coupe_modern"]},
	{"name": "Familiari moderne", "cars": ["wagon", "minivan"]},
	{"name": "Lusso e stile", "cars": ["limo", "lowrider"]},
	{"name": "Retro", "cars": ["atomic", "classic"]},
	{"name": "Fuoristrada", "cars": ["buggy", "rally"]},
	{"name": "Elettrica e muscle", "cars": ["electric", "muscle"]},
	{"name": "Polizia", "cars": ["police_90", "police_modern"]},
	{"name": "Vertice", "cars": ["sports_90", "hover"]},
	{"name": "Berline moderne", "cars": ["sedan_modern", "taxi_modern"]},
	{"name": "Sportiva e SUV", "cars": ["sports_modern", "suv_modern"]},
	{"name": "Pista", "cars": ["race_car", "sports_90"]},
]


func duel_level(car_id: String) -> int:
	for i in DUELS.size():
		if (DUELS[i]["cars"] as Array).has(car_id):
			return i + 1
	return 0


func duel_name(car_id: String) -> String:
	for duel in DUELS:
		if (duel["cars"] as Array).has(car_id):
			return str(duel["name"])
	return ""


func duel_label(car_id: String) -> String:
	var level := duel_level(car_id)
	if level <= 0:
		return "1v1"
	return tr("LIVELLO %d · %s") % [level, tr(duel_name(car_id)).to_upper()]


func roll_environment() -> String:
	var options: Array = ENV_PRESETS.ENVIRONMENTS.duplicate()
	if _environment_streak >= 2:
		options.erase(_last_environment)
	var picked := str(options.pick_random())
	if picked == _last_environment:
		_environment_streak += 1
	else:
		_last_environment = picked
		_environment_streak = 1
	race_environment = picked
	return race_environment


func pick_opponent() -> String:
	var options: Array = CARS.duplicate()
	if _last_opponent_id != "" and options.size() > 1:
		options.erase(_last_opponent_id)
	opponent_car_id = str(options.pick_random())
	_last_opponent_id = opponent_car_id
	return opponent_car_id


func opponent_car() -> String:
	if opponent_car_id == "":
		pick_opponent()
	return opponent_car_id


func player_name() -> String:
	return NAMES[player_car]


func opponent_name() -> String:
	return NAMES[opponent_car()]
