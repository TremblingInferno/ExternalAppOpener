tool
extends EditorPlugin


const FOLDER = "Assets" # leave blank for whole project
const EXTENSION = "svg"
const COMMAND = "inkscape" # bin executable name
const MENU_NAME = "Open Inkscape File"


var popups = []
var popup_menu


func _enter_tree():
	popup_menu = PopupMenu.new()
	popup_menu.connect("about_to_show", self, "update_files")
	popup_menu.connect("index_pressed", self, "open_file")
	add_tool_submenu_item(MENU_NAME, popup_menu)


func update_files():
	popup_menu.clear()
	popups = []
	var files = get_all_files(FOLDER, EXTENSION)
	for file in files:
		popup_menu.add_item(file.get_file())
		popups.append(file)


func open_file(idx):
	var file = popups[idx]
	var path = ProjectSettings.globalize_path(file)
	OS.execute(COMMAND, [path], false) # Can change the command's arguments


func get_all_files(path: String, file_ext := "", files := []):
	var dir = Directory.new()

	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir().plus_file(file_name), file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue

				files.append(dir.get_current_dir().plus_file(file_name))

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files


func _exit_tree():
	remove_tool_menu_item(MENU_NAME)
	popups = []
