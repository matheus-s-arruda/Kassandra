@tool
extends VBoxContainer

enum State {MENU, SCENE, SCRIPTS, RESOURCES, MATERIALS, MESHES, ALL}

var current_state := State.MENU:
	set(value):
		current_state = value
		
		label.visible = current_state == State.MENU
		menu.visible = current_state == State.MENU
		margin_container.visible = current_state != State.MENU
		
		scenes.visible = current_state == State.SCENE

var plugin: EditorPlugin

@onready var label = $Label
@onready var menu = $HBoxContainer
@onready var margin_container = $MarginContainer
@onready var scenes = $MarginContainer/scenes
@onready var itens_scene = $MarginContainer/scenes/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer


func install_scene(id: String):
	var filedialog = FileDialog.new()
	add_child(filedialog)
	filedialog.popup_centered()
	filedialog.size = Vector2(500, 300)
	filedialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	
	var dir_selected := [""]
	filedialog.dir_selected.connect(func(path: String): dir_selected[0] = path)
	filedialog.confirmed.connect(install_scene2.bind(id, dir_selected))
	filedialog.canceled.connect(func(): filedialog.queue_free())
	filedialog.show()


func install_scene2(id: String, dir_selected: Array):
	var path_file = plugin.data.scenes[id][3] + plugin.data.scenes[id][1].erase(0, 6)
	var read_file = FileAccess.open(path_file, FileAccess.READ)
	
	var target_path: String = dir_selected[0]
	if read_file:
		if target_path[-1] != "/":
			target_path += "/"
		
		target_path += plugin.data.scenes[id][0] + ".tscn"
		var white_file = FileAccess.open(target_path, FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)
			
			var split := content.split("\n")
			var index := 2
			while split[index].begins_with("[ext_resource"):
				var split2 := split[index].split(" ")
				for path in split2:
					if path.begins_with("path="):
						var resource_path = plugin.data.scenes[id][3] + path.replace("path=\"", "").replace("\"", "").erase(0, 6)
						copy_and_save(resource_path, path)
				index += 1


func copy_and_save(copy_path: String, save_path: String):
	var read_file = FileAccess.open(copy_path, FileAccess.READ)
	if read_file:
		var white_file = FileAccess.open(save_path, FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)


func remove_scene(id: String):
	var confirm_remove := ConfirmationDialog.new()
	add_child(confirm_remove)
	
	confirm_remove.exclusive = true
	confirm_remove.title = "Remove this item?"
	confirm_remove.dialog_text = "Caution! This action is irreversible."
	confirm_remove.popup_centered()
	
	confirm_remove.confirmed.connect(
		func():
			plugin.data.scenes.erase(id)
			plugin.save_data()
			load_data.call_deferred(plugin.data)
	)
	confirm_remove.canceled.connect(func(): confirm_remove.queue_free())
	confirm_remove.show()


func load_data(data: Dictionary):
	if not itens_scene:
		await ready
	itens_scene.load_scenes(data.scenes)


func _on_scenes_pressed():
	self.current_state = State.SCENE


func _on_return_pressed():
	self.current_state = State.MENU
