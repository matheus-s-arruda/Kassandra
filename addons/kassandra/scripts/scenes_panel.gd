@tool
extends VBoxContainer

const ITEM_SCENE = preload("res://addons/kassandra/scenes/item_scene.tscn")

@onready var editor = $"../../../../../.."


func load_scenes(scenes: Dictionary):
	get_children().map(func(c): c.queue_free())
	await get_tree().process_frame
	
	for scene in scenes:
		var item = create_item(scenes[scene])
		item.install.pressed.connect(install_scene.bind(scene))
		item.remove.pressed.connect(remove_scene.bind(scene))


func create_item(data: Array):
	var item := ITEM_SCENE.instantiate()
	item.data = data
	add_child(item)
	return item


func install_scene(id: String):
	var filedialog = FileDialog.new()
	add_child(filedialog)
	filedialog.popup_centered()
	filedialog.size = Vector2(500, 300)
	filedialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	
	var dir_selected := ["", ""]
	filedialog.dir_selected.connect(func(path: String): dir_selected[0] = path; dir_selected[1] = filedialog.get_line_edit().text)
	filedialog.confirmed.connect(install_scene2.bind(id, dir_selected))
	filedialog.canceled.connect(func(): filedialog.queue_free())
	filedialog.show()


func install_scene2(id: String, dir_selected: Array):
	var path_file = editor.plugin.data.scenes[id][3] + editor.plugin.data.scenes[id][1].erase(0, 6)
	var read_file = FileAccess.open(path_file, FileAccess.READ)
	var target_path: String = dir_selected[0]
	
	if read_file:
		if target_path[-1] != "/":
			target_path += "/"
		
		if dir_selected[1].is_empty():
			target_path += editor.plugin.data.scenes[id][0] + ".tscn"
		else:
			target_path += dir_selected[1] + ".tscn"
		
		var white_file = FileAccess.open(target_path, FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)
			
			KassandraBook.recover_procedural_resource(content, editor.plugin.data.scenes[id][3])


func remove_scene(id: String):
	var confirm_remove := ConfirmationDialog.new()
	add_child(confirm_remove)
	
	confirm_remove.exclusive = true
	confirm_remove.title = "Remove this item?"
	confirm_remove.dialog_text = "Caution! This action is irreversible."
	confirm_remove.popup_centered()
	
	confirm_remove.confirmed.connect(
		func():
			editor.plugin.data.scenes.erase(id)
			editor.plugin.save_data()
			editor.load_data.call_deferred(editor.plugin.data)
	)
	confirm_remove.canceled.connect(func(): confirm_remove.queue_free())
	confirm_remove.show()
