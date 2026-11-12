extends Node

const PACK_DIR := "res://localization"
const DEFAULT_LOCALE := "it"
const FALLBACK_LOCALE := "en"

# Le lingue disponibili nel selettore. Vengono mostrate solo quelle con un
# pacchetto presente in localization/ (l'italiano e' il testo sorgente).
const LANGUAGES := [
	{"code": "it", "label": "Italiano"},
	{"code": "en", "label": "English"},
	{"code": "es", "label": "Español"},
	{"code": "fr", "label": "Français"},
	{"code": "de", "label": "Deutsch"},
	{"code": "pt", "label": "Português"},
	{"code": "ru", "label": "Русский"},
	{"code": "ja", "label": "日本語"},
	{"code": "zh", "label": "中文"},
	{"code": "ko", "label": "한국어"},
	{"code": "ar", "label": "العربية"},
	{"code": "hi", "label": "हिन्दी"},
	{"code": "tr", "label": "Türkçe"},
	{"code": "pl", "label": "Polski"},
	{"code": "nl", "label": "Nederlands"},
	{"code": "nap", "label": "Napoletano"},
	{"code": "scn", "label": "Siciliano"},
	{"code": "vec", "label": "Veneto"},
	{"code": "srd", "label": "Sardo"},
	{"code": "fur", "label": "Friulano"},
]

var current := DEFAULT_LOCALE

var _available := {}


func _ready() -> void:
	_load_packs()
	apply(Settings.language)


func _load_packs() -> void:
	for language in LANGUAGES:
		var code: String = language["code"]
		var path := PACK_DIR.path_join(code + ".json")
		if not FileAccess.file_exists(path):
			if code == DEFAULT_LOCALE:
				_available[code] = true
			continue
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(data) != TYPE_DICTIONARY:
			push_warning("Pacchetto lingua non valido: " + path)
			continue
		var translation := Translation.new()
		translation.locale = code
		for key in data.keys():
			translation.add_message(str(key), str(data[key]))
		TranslationServer.add_translation(translation)
		_available[code] = true


func apply(code: String, persist := false) -> void:
	var resolved := code if _available.has(code) else DEFAULT_LOCALE
	current = resolved
	TranslationServer.set_locale(resolved)
	Settings.language = resolved
	if persist:
		Settings.save()


func set_language(code: String) -> void:
	apply(code, true)


func languages() -> Array:
	var result: Array = []
	for language in LANGUAGES:
		if _available.has(language["code"]):
			result.append(language)
	return result


func index_of(code: String) -> int:
	var list := languages()
	for i in list.size():
		if list[i]["code"] == code:
			return i
	return 0
