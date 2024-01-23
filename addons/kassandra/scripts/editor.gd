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
		scripts.visible = current_state == State.SCRIPTS

var plugin: EditorPlugin

@onready var label = $Label
@onready var menu = $HBoxContainer
@onready var itens_scene = $MarginContainer/scenes/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var itens_scripts = $MarginContainer/scripts/PanelContainer/MarginContainer/ScrollContainer/GridContainer

@onready var margin_container = $MarginContainer
@onready var scenes = $MarginContainer/scenes
@onready var scripts = $MarginContainer/scripts


func copy_and_save(copy_path: String, save_path: String):
	var read_file = FileAccess.open(copy_path, FileAccess.READ)
	if read_file:
		var base_path: String = save_path.get_base_dir().erase(0, 6)
		var split = base_path.split("/")
		var final_path: String = "res://"
		
		for i in split.size():
			final_path += split[i]
			if not DirAccess.dir_exists_absolute(final_path):
				DirAccess.make_dir_absolute(final_path)
			final_path += "/"
		
		var white_file = FileAccess.open(final_path + save_path.get_file(), FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)
			white_file.close()
			return true # sucesso
		read_file.close()
	# falha


func load_data(data: Dictionary):
	if not itens_scene:
		await ready
	
	itens_scene.load_scenes(data.scenes)
	itens_scripts.load_scripts(data.scripts)


func _on_scenes_pressed():
	self.current_state = State.SCENE


func _on_return_pressed():
	self.current_state = State.MENU


func _on_scripts_pressed():
	self.current_state = State.SCRIPTS
