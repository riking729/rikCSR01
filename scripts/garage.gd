extends Node

const FILE_NAME := "garage.cfg"

const COUPE := "coupe"
const POLICE := "police"
const SEDAN := "sedan"
const SPORTS := "sports"
const CITY := "city"
const TAXI := "taxi"
const SUV := "suv"
const SEDAN_50 := "sedan_50"
const WAGON_50 := "wagon_50"
const PICKUP_50 := "pickup_50"
const ROADSTER_50 := "roadster_50"
const CONVERTIBLE_60 := "convertible_60"
const COMPACT_60 := "compact_60"
const MICROBUS_60 := "microbus_60"
const SPORTS_60 := "sports_60"
const COUPE_70 := "coupe_70"
const HATCHBACK_70 := "hatchback_70"
const PICKUP_70 := "pickup_70"
const SEDAN_70 := "sedan_70"
const HATCHBACK_80 := "hatchback_80"
const SEDAN_80 := "sedan_80"
const SPORTS_80 := "sports_80"
const WAGON_80 := "wagon_80"
const VAN_80 := "van_80"
const COMPACT_90 := "compact_90"
const VAN_90 := "van_90"
const HATCHBACK_90 := "hatchback_90"
const MINIVAN_90 := "minivan_90"
const OFFROAD_90 := "offroad_90"
const PICKUP_90 := "pickup_90"
const POLICE_90 := "police_90"
const SEDAN_90 := "sedan_90"
const SPORTS_90 := "sports_90"
const WAGON_90 := "wagon_90"
const SUV_90 := "suv_90"
const TAXI_90 := "taxi_90"
const ATOMIC := "atomic"
const COMPACT := "compact"
const CONVERTIBLE := "convertible"
const COUPE_MODERN := "coupe_modern"
const BUGGY := "buggy"
const ELECTRIC := "electric"
const LOWRIDER := "lowrider"
const MICROCAR := "microcar"
const MINIVAN := "minivan"
const MUSCLE := "muscle"
const RALLY := "rally"
const WAGON := "wagon"
const LIMO := "limo"
const TUK_TUK := "tuk_tuk"
const CLASSIC := "classic"
const HATCHBACK := "hatchback"
const HOVER := "hover"
const POLICE_MODERN := "police_modern"
const RACE_CAR := "race_car"
const SEDAN_MODERN := "sedan_modern"
const SPORTS_MODERN := "sports_modern"
const SUV_MODERN := "suv_modern"
const TAXI_MODERN := "taxi_modern"

const CARS: Array[String] = [
	COUPE, SPORTS, SEDAN, CITY, POLICE, TAXI, SUV,
	SEDAN_50, WAGON_50, PICKUP_50, ROADSTER_50,
	CONVERTIBLE_60, COMPACT_60, MICROBUS_60, SPORTS_60,
	COUPE_70, HATCHBACK_70, PICKUP_70, SEDAN_70,
	HATCHBACK_80, SEDAN_80, SPORTS_80,
	WAGON_80, VAN_80, COMPACT_90, VAN_90, HATCHBACK_90,
	MINIVAN_90, OFFROAD_90, PICKUP_90, POLICE_90, SEDAN_90,
	SPORTS_90, WAGON_90, SUV_90, TAXI_90, ATOMIC, COMPACT,
	CONVERTIBLE, COUPE_MODERN, BUGGY, ELECTRIC, LOWRIDER,
	MICROCAR, MINIVAN, MUSCLE, RALLY, WAGON, LIMO, TUK_TUK,
	CLASSIC, HATCHBACK, HOVER, POLICE_MODERN,
	RACE_CAR, SEDAN_MODERN, SPORTS_MODERN, SUV_MODERN, TAXI_MODERN,
]

const STATS: Array[String] = ["top_speed", "transmission", "nos"]
const STAT_NAMES := {
	"top_speed": "Velocità max",
	"transmission": "Trasmissione",
	"nos": "Durata NOS",
}

# Statistiche 0-100: di serie stanno in 20-60, ogni livello aggiunge 4 punti.
# Ogni auto ha una terna di resti modulo 4 unica, quindi due auto non possono
# mai avere la stessa terna, né di serie né a qualunque livello di potenziamento.
const BASE_STATS := {
	"coupe": {"top_speed": 43, "transmission": 43, "nos": 40},
	"police": {"top_speed": 41, "transmission": 41, "nos": 36},
	"sedan": {"top_speed": 36, "transmission": 37, "nos": 44},
	"sports": {"top_speed": 51, "transmission": 47, "nos": 29},
	"city": {"top_speed": 33, "transmission": 36, "nos": 49},
	"taxi": {"top_speed": 31, "transmission": 35, "nos": 47},
	"suv": {"top_speed": 39, "transmission": 37, "nos": 39},
	"sedan_50": {"top_speed": 25, "transmission": 26, "nos": 29},
	"wagon_50": {"top_speed": 26, "transmission": 27, "nos": 32},
	"pickup_50": {"top_speed": 28, "transmission": 26, "nos": 36},
	"roadster_50": {"top_speed": 38, "transmission": 34, "nos": 27},
	"convertible_60": {"top_speed": 36, "transmission": 34, "nos": 29},
	"compact_60": {"top_speed": 31, "transmission": 32, "nos": 39},
	"microbus_60": {"top_speed": 26, "transmission": 29, "nos": 42},
	"sports_60": {"top_speed": 44, "transmission": 39, "nos": 27},
	"coupe_70": {"top_speed": 42, "transmission": 39, "nos": 34},
	"hatchback_70": {"top_speed": 35, "transmission": 36, "nos": 42},
	"pickup_70": {"top_speed": 33, "transmission": 30, "nos": 39},
	"sedan_70": {"top_speed": 36, "transmission": 37, "nos": 42},
	"hatchback_80": {"top_speed": 39, "transmission": 41, "nos": 44},
	"sedan_80": {"top_speed": 41, "transmission": 39, "nos": 42},
	"sports_80": {"top_speed": 52, "transmission": 49, "nos": 31},
	"wagon_80": {"top_speed": 38, "transmission": 38, "nos": 46},
	"van_80": {"top_speed": 29, "transmission": 32, "nos": 52},
	"compact_90": {"top_speed": 34, "transmission": 38, "nos": 44},
	"van_90": {"top_speed": 33, "transmission": 36, "nos": 54},
	"hatchback_90": {"top_speed": 37, "transmission": 40, "nos": 47},
	"minivan_90": {"top_speed": 35, "transmission": 36, "nos": 49},
	"offroad_90": {"top_speed": 40, "transmission": 38, "nos": 42},
	"pickup_90": {"top_speed": 39, "transmission": 34, "nos": 39},
	"police_90": {"top_speed": 44, "transmission": 42, "nos": 39},
	"sedan_90": {"top_speed": 42, "transmission": 41, "nos": 44},
	"sports_90": {"top_speed": 54, "transmission": 51, "nos": 35},
	"wagon_90": {"top_speed": 43, "transmission": 41, "nos": 49},
	"suv_90": {"top_speed": 41, "transmission": 38, "nos": 42},
	"taxi_90": {"top_speed": 32, "transmission": 36, "nos": 51},
	"atomic": {"top_speed": 49, "transmission": 43, "nos": 29},
	"compact": {"top_speed": 36, "transmission": 39, "nos": 46},
	"convertible": {"top_speed": 39, "transmission": 38, "nos": 36},
	"coupe_modern": {"top_speed": 45, "transmission": 45, "nos": 37},
	"buggy": {"top_speed": 38, "transmission": 41, "nos": 39},
	"electric": {"top_speed": 52, "transmission": 52, "nos": 45},
	"lowrider": {"top_speed": 34, "transmission": 40, "nos": 53},
	"microcar": {"top_speed": 25, "transmission": 29, "nos": 47},
	"minivan": {"top_speed": 38, "transmission": 37, "nos": 49},
	"muscle": {"top_speed": 47, "transmission": 42, "nos": 41},
	"rally": {"top_speed": 44, "transmission": 48, "nos": 46},
	"wagon": {"top_speed": 40, "transmission": 40, "nos": 48},
	"limo": {"top_speed": 34, "transmission": 30, "nos": 57},
	"tuk_tuk": {"top_speed": 20, "transmission": 23, "nos": 36},
	"classic": {"top_speed": 30, "transmission": 28, "nos": 32},
	"hatchback": {"top_speed": 38, "transmission": 40, "nos": 46},
	"hover": {"top_speed": 56, "transmission": 55, "nos": 49},
	"police_modern": {"top_speed": 47, "transmission": 44, "nos": 40},
	"race_car": {"top_speed": 60, "transmission": 57, "nos": 33},
	"sedan_modern": {"top_speed": 38, "transmission": 40, "nos": 47},
	"sports_modern": {"top_speed": 50, "transmission": 47, "nos": 37},
	"suv_modern": {"top_speed": 41, "transmission": 39, "nos": 44},
	"taxi_modern": {"top_speed": 33, "transmission": 37, "nos": 50},
}

# Moltiplicatori reali di serie e guadagno per ogni livello acquistato.
# Verificato: a serie, al massimo e a parità di livelli due auto non hanno mai
# la stessa terna di performance.
const BASE_PERFORMANCE := {
	"coupe": {"top_speed": 1.03, "transmission": 1.04, "nos": 0.98},
	"police": {"top_speed": 1.02, "transmission": 1.03, "nos": 0.95},
	"sedan": {"top_speed": 0.98, "transmission": 0.99, "nos": 1.02},
	"sports": {"top_speed": 1.06, "transmission": 1.08, "nos": 0.92},
	"city": {"top_speed": 0.96, "transmission": 0.98, "nos": 1.04},
	"taxi": {"top_speed": 0.95, "transmission": 0.97, "nos": 1.03},
	"suv": {"top_speed": 1.01, "transmission": 0.98, "nos": 1.0},
	"sedan_50": {"top_speed": 0.88, "transmission": 0.92, "nos": 0.96},
	"wagon_50": {"top_speed": 0.89, "transmission": 0.91, "nos": 0.98},
	"pickup_50": {"top_speed": 0.9, "transmission": 0.9, "nos": 1.0},
	"roadster_50": {"top_speed": 1.0, "transmission": 0.99, "nos": 0.92},
	"convertible_60": {"top_speed": 0.98, "transmission": 0.97, "nos": 0.94},
	"compact_60": {"top_speed": 0.94, "transmission": 0.96, "nos": 1.0},
	"microbus_60": {"top_speed": 0.9, "transmission": 0.94, "nos": 1.04},
	"sports_60": {"top_speed": 1.04, "transmission": 1.05, "nos": 0.92},
	"coupe_70": {"top_speed": 1.02, "transmission": 1.03, "nos": 0.96},
	"hatchback_70": {"top_speed": 0.97, "transmission": 0.99, "nos": 1.02},
	"pickup_70": {"top_speed": 0.95, "transmission": 0.94, "nos": 1.0},
	"sedan_70": {"top_speed": 0.98, "transmission": 0.99, "nos": 1.03},
	"hatchback_80": {"top_speed": 1.0, "transmission": 1.02, "nos": 1.04},
	"sedan_80": {"top_speed": 1.01, "transmission": 1.01, "nos": 1.02},
	"sports_80": {"top_speed": 1.06, "transmission": 1.08, "nos": 0.94},
	"wagon_80": {"top_speed": 1.0, "transmission": 1.0, "nos": 1.03},
	"van_80": {"top_speed": 0.93, "transmission": 0.95, "nos": 1.05},
	"compact_90": {"top_speed": 0.96, "transmission": 1.0, "nos": 1.025},
	"van_90": {"top_speed": 0.94, "transmission": 0.97, "nos": 1.06},
	"hatchback_90": {"top_speed": 0.98, "transmission": 1.01, "nos": 1.03},
	"minivan_90": {"top_speed": 0.97, "transmission": 0.98, "nos": 1.04},
	"offroad_90": {"top_speed": 1.02, "transmission": 0.99, "nos": 1.0},
	"pickup_90": {"top_speed": 1.0, "transmission": 0.95, "nos": 0.98},
	"police_90": {"top_speed": 1.03, "transmission": 1.02, "nos": 0.96},
	"sedan_90": {"top_speed": 1.01, "transmission": 1.0, "nos": 1.01},
	"sports_90": {"top_speed": 1.08, "transmission": 1.09, "nos": 0.96},
	"wagon_90": {"top_speed": 1.02, "transmission": 1.01, "nos": 1.02},
	"suv_90": {"top_speed": 1.01, "transmission": 0.98, "nos": 0.99},
	"taxi_90": {"top_speed": 0.95, "transmission": 0.97, "nos": 1.04},
	"atomic": {"top_speed": 1.05, "transmission": 1.03, "nos": 0.9},
	"compact": {"top_speed": 0.97, "transmission": 1.0, "nos": 1.02},
	"convertible": {"top_speed": 1.0, "transmission": 0.99, "nos": 0.94},
	"coupe_modern": {"top_speed": 1.04, "transmission": 1.05, "nos": 0.95},
	"buggy": {"top_speed": 0.99, "transmission": 1.04, "nos": 0.97},
	"electric": {"top_speed": 1.07, "transmission": 1.1, "nos": 1.08},
	"lowrider": {"top_speed": 0.96, "transmission": 1.02, "nos": 1.07},
	"microcar": {"top_speed": 0.88, "transmission": 0.92, "nos": 1.03},
	"minivan": {"top_speed": 0.99, "transmission": 0.99, "nos": 1.04},
	"muscle": {"top_speed": 1.05, "transmission": 1.02, "nos": 0.99},
	"rally": {"top_speed": 1.03, "transmission": 1.08, "nos": 1.05},
	"wagon": {"top_speed": 1.0, "transmission": 1.0, "nos": 1.07},
	"limo": {"top_speed": 0.95, "transmission": 0.93, "nos": 1.08},
	"tuk_tuk": {"top_speed": 0.8, "transmission": 0.85, "nos": 0.95},
	"classic": {"top_speed": 0.92, "transmission": 0.93, "nos": 0.96},
	"hatchback": {"top_speed": 0.99, "transmission": 1.02, "nos": 1.02},
	"hover": {"top_speed": 1.12, "transmission": 1.12, "nos": 1.06},
	"police_modern": {"top_speed": 1.04, "transmission": 1.02, "nos": 0.97},
	"race_car": {"top_speed": 1.1, "transmission": 1.08, "nos": 0.94},
	"sedan_modern": {"top_speed": 0.99, "transmission": 1.01, "nos": 1.03},
	"sports_modern": {"top_speed": 1.05, "transmission": 1.06, "nos": 0.97},
	"suv_modern": {"top_speed": 1.015, "transmission": 0.995, "nos": 1.015},
	"taxi_modern": {"top_speed": 0.955, "transmission": 0.975, "nos": 1.045},
}
const LEVEL_STEP := {"top_speed": 0.008, "transmission": 0.02, "nos": 0.07}

const STAT_GAIN := 4
const MAX_LEVEL := 10
const START_CREDITS := 10000
const START_GOLD := 50
const WIN_REWARD := 2000
const LOSE_REWARD := 800
const WIN_GOLD := 5
const LOSE_GOLD := 2

# Prezzi in CR$. La coupe e' inclusa nell'acquisto iniziale.
const CAR_PRICES := {
	"coupe": 12000,
	"police": 16000,
	"sedan": 14000,
	"sports": 22000,
	"city": 9000,
	"taxi": 8000,
	"suv": 18000,
	"sedan_50": 7000,
	"wagon_50": 7500,
	"pickup_50": 8000,
	"roadster_50": 11000,
	"convertible_60": 13000,
	"compact_60": 8000,
	"microbus_60": 10000,
	"sports_60": 17000,
	"coupe_70": 15000,
	"hatchback_70": 10000,
	"pickup_70": 11000,
	"sedan_70": 13000,
	"hatchback_80": 12000,
	"sedan_80": 14000,
	"sports_80": 24000,
	"wagon_80": 12500,
	"van_80": 9500,
	"compact_90": 10500,
	"van_90": 11000,
	"hatchback_90": 12000,
	"minivan_90": 13000,
	"offroad_90": 16000,
	"pickup_90": 14000,
	"police_90": 18000,
	"sedan_90": 15000,
	"sports_90": 26000,
	"wagon_90": 16500,
	"suv_90": 17000,
	"taxi_90": 8500,
	"atomic": 21000,
	"compact": 10000,
	"convertible": 14500,
	"coupe_modern": 18500,
	"buggy": 12500,
	"electric": 27000,
	"lowrider": 15500,
	"microcar": 6000,
	"minivan": 14000,
	"muscle": 22500,
	"rally": 24000,
	"wagon": 14000,
	"limo": 20000,
	"tuk_tuk": 4500,
	"classic": 7500,
	"hatchback": 11500,
	"hover": 40000,
	"police_modern": 19000,
	"race_car": 36000,
	"sedan_modern": 13000,
	"sports_modern": 24500,
	"suv_modern": 18500,
	"taxi_modern": 9000,
}

var credits := START_CREDITS
var gold := START_GOLD

var _levels := {}
var _owned := {}
var _path: String


func _ready() -> void:
	_path = _garage_path()
	_load()


func _garage_path() -> String:
	var base_dir := OS.get_executable_path().get_base_dir()
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	return base_dir.path_join(FILE_NAME)


func _load() -> void:
	credits = START_CREDITS
	gold = START_GOLD
	_levels = {}
	_owned = {COUPE: true}
	for car in CARS:
		_levels[car] = {}
		for stat in STATS:
			_levels[car][stat] = 0

	var config := ConfigFile.new()
	if config.load(_path) != OK:
		return

	credits = int(config.get_value("wallet", "credits", START_CREDITS))
	gold = int(config.get_value("wallet", "gold", START_GOLD))
	for car in CARS:
		for stat in STATS:
			_levels[car][stat] = clampi(int(config.get_value(car, stat, 0)), 0, MAX_LEVEL)
		if config.has_section("owned") and bool(config.get_value("owned", car, false)):
			_owned[car] = true


func reset_progress() -> void:
	credits = START_CREDITS
	gold = START_GOLD
	_owned = {COUPE: true}
	for car in CARS:
		for stat in STATS:
			_levels[car][stat] = 0
	save()


func save() -> void:
	var config := ConfigFile.new()
	config.set_value("wallet", "credits", credits)
	config.set_value("wallet", "gold", gold)
	for car in CARS:
		for stat in STATS:
			config.set_value(car, stat, _levels[car][stat])
		if _owned.has(car):
			config.set_value("owned", car, true)
	var error := config.save(_path)
	if error != OK:
		push_warning("Could not save garage to %s (error %d)" % [_path, error])


func is_owned(car: String) -> bool:
	return _owned.has(car)


func car_price(car: String) -> int:
	return int(CAR_PRICES.get(car, 0))


func buy_car(car: String) -> bool:
	if is_owned(car) or not CAR_PRICES.has(car):
		return false
	var price: int = CAR_PRICES[car]
	if credits < price:
		return false
	credits -= price
	_owned[car] = true
	save()
	return true


func level(car: String, stat: String) -> int:
	return int(_levels[car][stat])


func stat_value(car: String, stat: String) -> int:
	var base: int = BASE_STATS[car][stat]
	return base + STAT_GAIN * level(car, stat)


func upgrade_cost(car: String, stat: String) -> int:
	var current := level(car, stat)
	if current >= MAX_LEVEL:
		return 0
	return (current + 1) * 1000


func buy_upgrade(car: String, stat: String) -> bool:
	var cost := upgrade_cost(car, stat)
	if cost <= 0 or credits < cost:
		return false
	credits -= cost
	_levels[car][stat] += 1
	save()
	return true


func performance(car: String, stat: String) -> float:
	var base: float = BASE_PERFORMANCE[car][stat]
	return base * (1.0 + level(car, stat) * LEVEL_STEP[stat])


func base_performance(car: String, stat: String) -> float:
	return BASE_PERFORMANCE[car][stat]


func best_base_performance(stat: String) -> float:
	var best := 0.0
	for car in CARS:
		best = maxf(best, float(BASE_PERFORMANCE[car][stat]))
	return best


func award_race(player_won: bool) -> int:
	var prize := WIN_REWARD if player_won else LOSE_REWARD
	credits += prize
	save()
	return prize


func add_credits(amount: int) -> void:
	credits += amount
	save()


func award_gold(player_won: bool) -> int:
	var amount := WIN_GOLD if player_won else LOSE_GOLD
	gold += amount
	save()
	return amount


func add_gold(amount: int) -> void:
	gold += amount
	save()


func spend_gold(amount: int) -> bool:
	if amount <= 0 or gold < amount:
		return false
	gold -= amount
	save()
	return true


func _format_number(value: int) -> String:
	var text := str(absi(value))
	var grouped := ""
	var count := 0
	for i in range(text.length() - 1, -1, -1):
		grouped = text[i] + grouped
		count += 1
		if count % 3 == 0 and i > 0:
			grouped = "." + grouped
	return ("-" if value < 0 else "") + grouped


func format_credits(value: int) -> String:
	return _format_number(value) + " CR$"


func format_gold(value: int) -> String:
	return _format_number(value) + " CR Gold"
