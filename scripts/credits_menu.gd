extends Control

const CC0 := "https://creativecommons.org/publicdomain/zero/1.0/"
const CC_BY_3 := "https://creativecommons.org/licenses/by/3.0/"
const CC_BY_4 := "https://creativecommons.org/licenses/by/4.0/"
const CC_BY_SA_3 := "https://creativecommons.org/licenses/by-sa/3.0/"
const CHOSIC := "https://www.chosic.com/"
const LINK_COLOR := "#ffc74d"

const SECTIONS := [
	{
		"title": "AUTO 3D",
		"entries": [
			{
				"name": "Quaternius",
				"work": "Cars Pack 2018: Coupé, Sportiva GT, Berlina, City Car, Auto della Polizia, Taxi e SUV",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "quaternius.com",
				"source_url": "https://quaternius.com/packs/cars.html",
			},
			{
				"name": "Grab3D",
				"work": "52 auto generiche anni '50-'90 e moderne: pickup, station wagon, berline, roadster, cabriolet, utilitarie, microbus, coupé, hatchback, sportive, SUV, van, fuoristrada, taxi, auto della polizia, lowrider, limousine, microcar, dune buggy, tuk tuk, hover car e auto da corsa (modelli senza marchio)",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "grab3d.com",
				"source_url": "https://grab3d.com/",
			},
			{
				"name": "Kenney",
				"work": "Car Kit 3.1",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "kenney.nl",
				"source_url": "https://kenney.nl/assets/car-kit",
			},
		],
	},
	{
		"title": "MUSICA",
		"entries": [
			{
				"name": "Alex-Productions",
				"work": "Phonk Execution · Aggressive Phonk - Metaphonk · Sport Rock & Workout - HARD · Powerful Trap Beat - Strong · Extreme Sport Trap Music - PISTA · Cyberpunk Computer Game - IDRA · Champion",
				"license": "CC BY 3.0",
				"license_url": CC_BY_3,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Kevin MacLeod",
				"work": "Neon Laser Horizon · Miami Nights - Extended Theme · Future Gladiator · Laser Groove · Metalmania · Hotrock",
				"license": "CC BY 4.0",
				"license_url": CC_BY_4,
				"source": "incompetech.com",
				"source_url": "https://incompetech.com/music/royalty-free/",
			},
			{
				"name": "Loyalty Freak Music",
				"work": "Can't Stop My Feet ! · High Technologic Beat Explosion",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Soft and Furious",
				"work": "C L I M A X",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Purrple Cat",
				"work": "Daydreams · Sonder",
				"license": "CC BY-SA 3.0",
				"license_url": CC_BY_SA_3,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Tokyo Music Walker",
				"work": "Echoes In Blue · Sunset Drive",
				"license": "CC BY 3.0",
				"license_url": CC_BY_3,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Ghostrifter Official",
				"work": "Unbound",
				"license": "CC BY-SA 3.0",
				"license_url": CC_BY_SA_3,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Alexander Nakarada",
				"work": "Battle Metal",
				"license": "CC BY 4.0",
				"license_url": CC_BY_4,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Punch Deck",
				"work": "I Can't Stop · Music To Wear Fingerless Gloves To",
				"license": "CC BY 3.0",
				"license_url": CC_BY_3,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
			{
				"name": "Frederic Lardon",
				"work": "It's A Trap",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "chosic.com",
				"source_url": CHOSIC,
			},
		],
	},
	{
		"title": "SUONI",
		"entries": [
			{
				"name": "Generati per questo progetto",
				"work": "Loop motore per auto (59 file) · gear_shift.wav (cambio marcia) · ui_hover.ogg (interfaccia)",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "creati proceduralmente",
				"source_url": "",
				"translate": true,
			},
		],
	},
	{
		"title": "IMMAGINI",
		"entries": [
			{
				"name": "Pexels",
				"work": "8 fotografie di garage usate come sfondo del menu",
				"license": "Licenza Pexels",
				"license_url": "https://www.pexels.com/license/",
				"source": "pexels.com",
				"source_url": "https://www.pexels.com/",
				"translate": true,
			},
			{
				"name": "Render di gioco",
				"work": "59 fotografie delle auto del gioco usate nella presentazione iniziale, renderizzate dal motore con le luci del garage",
				"license": "CC0 1.0",
				"license_url": CC0,
				"source": "questo progetto",
				"source_url": "",
				"translate": true,
			},
		],
	},
	{
		"title": "MOTORE",
		"entries": [
			{
				"name": "Godot Engine 4.7.2",
				"work": "Motore di gioco",
				"license": "MIT",
				"license_url": "https://godotengine.org/license",
				"source": "godotengine.org",
				"source_url": "https://godotengine.org/",
				"translate": true,
			},
		],
	},
]

@onready var entries: VBoxContainer = %Entries
@onready var back_button: Button = %BackButton


func _ready() -> void:
	_build_entries()
	AudioManager.connect_button_sfx(self)
	back_button.grab_focus()


func _build_entries() -> void:
	for section in SECTIONS:
		var header := Label.new()
		header.text = tr(str(section["title"]))
		header.add_theme_font_size_override("font_size", 18)
		header.add_theme_color_override("font_color", Color(1.0, 0.78, 0.3))
		entries.add_child(header)

		for entry in section["entries"]:
			var label := RichTextLabel.new()
			label.bbcode_enabled = true
			label.fit_content = true
			label.scroll_active = false
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			label.add_theme_font_size_override("normal_font_size", 15)
			label.add_theme_font_size_override("bold_font_size", 16)
			label.add_theme_color_override("default_color", Color(0.86, 0.88, 0.92))
			label.text = _entry_text(entry)
			label.meta_clicked.connect(_on_meta_clicked)
			entries.add_child(label)


func _entry_text(entry: Dictionary) -> String:
	var license := _link(entry["license_url"], entry["license"])
	var source := _link(entry["source_url"], entry["source"])
	var name := tr(str(entry["name"])) if entry.get("translate", false) else str(entry["name"])
	var work := tr(str(entry["work"])) if entry.get("translate", false) else str(entry["work"])
	var license_text := tr(str(entry["license"])) if entry.get("translate", false) else str(entry["license"])
	return "[b]%s[/b]\n%s\n%s · %s" % [name, work, license_text, source]


func _link(url: String, text: String) -> String:
	if url.is_empty():
		return text
	return "[color=%s][url=%s]%s[/url][/color]" % [LINK_COLOR, url, text]


func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn")
