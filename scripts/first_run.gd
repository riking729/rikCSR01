extends Node

const MARKER_NAME := "desktop_shortcut.cfg"
const SHORTCUT_NAME := "rikCSR01"

const RESULT_SKIPPED := 0
const RESULT_CREATED := 1
const RESULT_FAILED := 2

signal notice_closed

var _notice_shown := false
var _notice_pending := false


func _ready() -> void:
	if OS.has_feature("editor") or OS.get_name() != "Windows":
		return
	var exe_path := OS.get_executable_path()
	var desktop_dir := OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	var result := ensure_desktop_shortcut(exe_path.get_base_dir(), desktop_dir, exe_path)
	if result == RESULT_CREATED:
		_notice_pending = true
		show_notice(_created_text())
	elif result == RESULT_FAILED:
		_notice_pending = true
		show_notice(_failed_text())


func ensure_desktop_shortcut(base_dir: String, desktop_dir: String, exe_path: String) -> int:
	if desktop_dir.is_empty() or exe_path.is_empty():
		return RESULT_FAILED
	var marker_path := base_dir.path_join(MARKER_NAME)
	if FileAccess.file_exists(marker_path):
		return RESULT_SKIPPED
	if not _create_shortcut(desktop_dir, exe_path):
		return RESULT_FAILED
	var marker := FileAccess.open(marker_path, FileAccess.WRITE)
	if marker != null:
		marker.store_string("Desktop shortcut created for %s" % exe_path)
		marker.close()
	return RESULT_CREATED


func _create_shortcut(desktop_dir: String, exe_path: String) -> bool:
	var link_path := desktop_dir.path_join(SHORTCUT_NAME + ".lnk")
	var script := "; ".join(PackedStringArray([
		"$ws = New-Object -ComObject WScript.Shell",
		"$s = $ws.CreateShortcut(%s)" % _ps_quote(link_path),
		"$s.TargetPath = %s" % _ps_quote(exe_path),
		"$s.WorkingDirectory = %s" % _ps_quote(exe_path.get_base_dir()),
		"$s.IconLocation = %s" % _ps_quote(exe_path + ",0"),
		"$s.Description = %s" % _ps_quote(SHORTCUT_NAME),
		"$s.Save()",
		"if (-not (Test-Path -LiteralPath %s)) { exit 1 }" % _ps_quote(link_path),
	]))
	var output: Array = []
	var code := OS.execute(
		"powershell.exe",
		PackedStringArray([
			"-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-Command", script
		]),
		output,
		true,
		false
	)
	return code == 0 and FileAccess.file_exists(link_path)


func _ps_quote(value: String) -> String:
	return "'" + value.replace("'", "''") + "'"


func is_notice_pending() -> bool:
	return _notice_pending


func show_notice(text: String) -> void:
	if _notice_shown:
		return
	_notice_shown = true
	_notice_pending = true
	var dialog := build_notice(text)
	dialog.confirmed.connect(_on_notice_closed.bind(dialog))
	dialog.canceled.connect(_on_notice_closed.bind(dialog))
	add_child(dialog)
	dialog.popup_centered()


func _on_notice_closed(dialog: AcceptDialog) -> void:
	if not _notice_pending:
		return
	_notice_pending = false
	if is_instance_valid(dialog):
		dialog.queue_free()
	notice_closed.emit()


func build_notice(text: String) -> AcceptDialog:
	var dialog := AcceptDialog.new()
	dialog.title = "Desktop shortcut"
	dialog.dialog_text = text
	dialog.ok_button_text = "OK"
	dialog.dialog_autowrap = true
	dialog.min_size = Vector2i(540, 150)
	dialog.exclusive = true
	dialog.borderless = true
	return dialog


func _created_text() -> String:
	return (
		"A shortcut to rikCSR01 has been created on your desktop.\n\n"
		+ "If you delete it, you can recreate it by deleting the file \""
		+ MARKER_NAME
		+ "\" from the game folder and launching the game again."
	)


func _failed_text() -> String:
	return (
		"The desktop shortcut could not be created.\n\n"
		+ "You can create it manually: right-click the game executable, choose "
		+ "\"Send to\" and then \"Desktop (create shortcut)\"."
	)
