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
		var base_path: String = save_path.get_base_dir()
		base_path = ProjectSettings.globalize_path(base_path)
		if not DirAccess.dir_exists_absolute(base_path):
			DirAccess.make_dir_absolute(base_path)
		
		var white_file = FileAccess.open(save_path, FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)


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
