extends RefCounted

# Generated: engine timbre and rev envelope per car.

const ENGINES := {
	"diesel": {
		"idle": 0.52, "max": 1.8, "idle_db": -17, "max_db": -7.5, "shift": 0.85,
	},
	"electric": {
		"idle": 0.85, "max": 1.85, "idle_db": -22, "max_db": -14, "shift": 1,
	},
	"flat4": {
		"idle": 0.63, "max": 2.08, "idle_db": -18.5, "max_db": -8.5, "shift": 1,
	},
	"flat6": {
		"idle": 0.65, "max": 2.22, "idle_db": -19, "max_db": -8.5, "shift": 1.05,
	},
	"hover": {
		"idle": 0.8, "max": 1.7, "idle_db": -21, "max_db": -13, "shift": 1,
	},
	"inline3": {
		"idle": 0.7, "max": 2.3, "idle_db": -19, "max_db": -9, "shift": 1.05,
	},
	"inline4": {
		"idle": 0.66, "max": 2.15, "idle_db": -18.5, "max_db": -8.5, "shift": 1.02,
	},
	"inline6": {
		"idle": 0.62, "max": 2.1, "idle_db": -18.5, "max_db": -8.5, "shift": 1,
	},
	"muscle": {
		"idle": 0.55, "max": 2.05, "idle_db": -17.5, "max_db": -7.5, "shift": 0.9,
	},
	"single": {
		"idle": 0.48, "max": 1.6, "idle_db": -17.5, "max_db": -9, "shift": 0.8,
	},
	"two_cyl": {
		"idle": 0.6, "max": 1.9, "idle_db": -19.5, "max_db": -10, "shift": 0.95,
	},
	"v10": {
		"idle": 0.68, "max": 2.25, "idle_db": -18.5, "max_db": -8, "shift": 1.06,
	},
	"v12": {
		"idle": 0.7, "max": 2.32, "idle_db": -18, "max_db": -7.5, "shift": 1.1,
	},
	"v6": {
		"idle": 0.63, "max": 2.12, "idle_db": -18.5, "max_db": -8.5, "shift": 1,
	},
	"v8": {
		"idle": 0.58, "max": 2, "idle_db": -18, "max_db": -8, "shift": 0.94,
	},
	"v8_smooth": {
		"idle": 0.56, "max": 1.92, "idle_db": -19, "max_db": -9.5, "shift": 0.9,
	},
	"vintage": {
		"idle": 0.58, "max": 1.85, "idle_db": -18, "max_db": -9, "shift": 0.92,
	},
}

const CAR_ENGINE := {
	"coupe": {"family": "v6", "pitch": 0.971, "db": 0.44},
	"sports": {"family": "v8", "pitch": 0.997, "db": 0.36},
	"sedan": {"family": "v6", "pitch": 1.01, "db": -0.53},
	"city": {"family": "inline3", "pitch": 1.006, "db": -0.4},
	"police": {"family": "v8", "pitch": 1.015, "db": -0.11},
	"taxi": {"family": "inline4", "pitch": 1.019, "db": 0.52},
	"suv": {"family": "v6", "pitch": 1.002, "db": -0.29},
	"sedan_50": {"family": "vintage", "pitch": 0.995, "db": -0.26},
	"wagon_50": {"family": "vintage", "pitch": 1.016, "db": -0.41},
	"pickup_50": {"family": "vintage", "pitch": 1.029, "db": -0.53},
	"roadster_50": {"family": "vintage", "pitch": 1.006, "db": 0.22},
	"convertible_60": {"family": "inline6", "pitch": 1.019, "db": 0.2},
	"compact_60": {"family": "flat4", "pitch": 0.97, "db": 0.09},
	"microbus_60": {"family": "flat4", "pitch": 1.002, "db": 0.06},
	"sports_60": {"family": "inline6", "pitch": 1.005, "db": 0.38},
	"coupe_70": {"family": "v8", "pitch": 0.995, "db": -0.22},
	"hatchback_70": {"family": "inline4", "pitch": 1.008, "db": -0.19},
	"pickup_70": {"family": "v8", "pitch": 0.974, "db": 0.25},
	"sedan_70": {"family": "inline6", "pitch": 0.975, "db": 0.44},
	"hatchback_80": {"family": "inline4", "pitch": 0.996, "db": 0.34},
	"sedan_80": {"family": "inline6", "pitch": 1.022, "db": 0.38},
	"sports_80": {"family": "v8", "pitch": 0.992, "db": -0.25},
	"wagon_80": {"family": "inline6", "pitch": 0.988, "db": 0.55},
	"van_80": {"family": "diesel", "pitch": 0.984, "db": -0.44},
	"compact_90": {"family": "inline3", "pitch": 1.005, "db": -0.06},
	"van_90": {"family": "diesel", "pitch": 0.981, "db": -0.46},
	"hatchback_90": {"family": "inline4", "pitch": 0.975, "db": 0.5},
	"minivan_90": {"family": "v6", "pitch": 1.011, "db": 0.21},
	"offroad_90": {"family": "flat4", "pitch": 0.993, "db": -0.18},
	"pickup_90": {"family": "diesel", "pitch": 0.984, "db": 0.4},
	"police_90": {"family": "v8", "pitch": 0.986, "db": -0.34},
	"sedan_90": {"family": "v6", "pitch": 1.027, "db": 0.24},
	"sports_90": {"family": "flat6", "pitch": 0.984, "db": 0.07},
	"wagon_90": {"family": "inline6", "pitch": 0.987, "db": -0.21},
	"suv_90": {"family": "v6", "pitch": 1.023, "db": -0.58},
	"taxi_90": {"family": "inline4", "pitch": 1.013, "db": 0.12},
	"atomic": {"family": "v8_smooth", "pitch": 0.985, "db": 0.36},
	"compact": {"family": "inline3", "pitch": 1.02, "db": 0.12},
	"convertible": {"family": "v6", "pitch": 1.005, "db": -0.42},
	"coupe_modern": {"family": "v6", "pitch": 0.989, "db": -0.36},
	"buggy": {"family": "flat4", "pitch": 1.008, "db": -0.48},
	"electric": {"family": "electric", "pitch": 0.985, "db": 0.55},
	"lowrider": {"family": "v8_smooth", "pitch": 0.995, "db": -0.3},
	"microcar": {"family": "two_cyl", "pitch": 0.98, "db": 0.19},
	"minivan": {"family": "v6", "pitch": 1.029, "db": 0.59},
	"muscle": {"family": "muscle", "pitch": 0.982, "db": 0.43},
	"rally": {"family": "flat4", "pitch": 0.99, "db": 0.42},
	"wagon": {"family": "v6", "pitch": 0.975, "db": 0.41},
	"limo": {"family": "v8_smooth", "pitch": 0.972, "db": -0.04},
	"tuk_tuk": {"family": "single", "pitch": 0.996, "db": -0.4},
	"classic": {"family": "vintage", "pitch": 1.02, "db": 0.48},
	"hatchback": {"family": "inline3", "pitch": 1.026, "db": -0.11},
	"hover": {"family": "hover", "pitch": 0.973, "db": 0.54},
	"police_modern": {"family": "v8", "pitch": 1.019, "db": -0.28},
	"race_car": {"family": "v12", "pitch": 0.971, "db": 0.06},
	"sedan_modern": {"family": "v6", "pitch": 0.997, "db": -0.56},
	"sports_modern": {"family": "v10", "pitch": 1.03, "db": -0.01},
	"suv_modern": {"family": "v8", "pitch": 0.977, "db": -0.12},
	"taxi_modern": {"family": "inline4", "pitch": 0.988, "db": 0.42},
}
