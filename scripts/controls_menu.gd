extends Control

const ACTIONS: Array[String] = [
	"accelerate", "accelerate", "brake", "brake", "shift_gear", "nitro",
]
const INDICES: Array[int] = [0, 1, 0, 1, 0, 0]
const LABELS: Array[String] = [
	"Accelera", "Accelera (frecce)", "Freno", "Freno (frecce)", "Cambia marcia", "Nitro",
]

@onready var rows: VBoxContainer = %Rows
@onready var message: Label = %Message
@onready var back_button: Button = %BackButton

var _buttons: Array[Button] = []
var _listening := -1


func _ready() -> void:
	message.text = ""
	for index in ACTIONS.size():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)

		var label := Label.new()
		label.text = tr(LABELS[index])
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 18)
		row.add_child(label)

		var button := Button.new()
		button.custom_minimum_size = Vector2(160, 44)
		button.pressed.connect(_on_bind_button_pressed.bind(index))
		row.add_child(button)

		rows.add_child(row)
		_buttons.append(button)

	_refresh_buttons()
	AudioManager.connect_button_sfx(self)
	_buttons[0].grab_focus()


func _refresh_buttons() -> void:
	for index in _buttons.size():
		if _listening == index:
			_buttons[index].text = tr("Premi un tasto...")
		else:
			_buttons[index].text = _key_text(_get_key(index))


func _get_key(row: int) -> Key:
	var events := InputMap.action_get_events(ACTIONS[row])
	if INDICES[row] >= events.size():
		return KEY_NONE
	var event := events[INDICES[row]]
	if not event is InputEventKey:
		return KEY_NONE
	return (event as InputEventKey).physical_keycode


func _on_bind_button_pressed(row: int) -> void:
	_listening = row
	message.text = ""
	_buttons[row].release_focus()
	_refresh_buttons()


func _input(event: InputEvent) -> void:
	if _listening < 0:
		return
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.physical_keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_cancel_listening()
		return
	if not _is_allowed(key_event.physical_keycode):
		return

	get_viewport().set_input_as_handled()
	_try_assign(_listening, key_event.physical_keycode)


func _try_assign(row: int, code: Key) -> void:
	if _is_key_used(code, row):
		message.text = tr("Tasto già usato da un altro comando")
		_cancel_listening()
		return

	var action := ACTIONS[row]
	var index := INDICES[row]
	var events := InputMap.action_get_events(action)
	var new_events: Array[InputEvent] = []
	for i in events.size():
		if i == index:
			var key_event := InputEventKey.new()
			key_event.physical_keycode = code
			new_events.append(key_event)
		else:
			new_events.append(events[i])

	InputMap.action_erase_events(action)
	for event in new_events:
		InputMap.action_add_event(action, event)

	Settings.save()
	_cancel_listening()


func _is_key_used(code: Key, except_row: int) -> bool:
	for row in ACTIONS.size():
		if row == except_row:
			continue
		if _get_key(row) == code:
			return true
	return false


func _is_allowed(code: Key) -> bool:
	return (code >= KEY_A and code <= KEY_Z) or (code >= KEY_0 and code <= KEY_9)


func _cancel_listening() -> void:
	_listening = -1
	_refresh_buttons()


func _key_text(code: Key) -> String:
	match code:
		KEY_UP:
			return "\u2191"
		KEY_DOWN:
			return "\u2193"
		KEY_LEFT:
			return "\u2190"
		KEY_RIGHT:
			return "\u2192"
		KEY_SPACE:
			return "SPAZIO"
		KEY_ESCAPE:
			return "ESC"
		KEY_NONE:
			return "-"
	return OS.get_keycode_string(code).to_upper()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn")
