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
		resources.visible = current_state == State.RESOURCES
		materials.visible = current_state == State.MATERIALS

var plugin: EditorPlugin

@onready var label = $Label
@onready var menu = $HBoxContainer
@onready var itens_scene = $MarginContainer/scenes/PanelContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var itens_scripts = $MarginContainer/scripts/PanelContainer/MarginContainer/ScrollContainer/GridContainer
@onready var itens_resources = $MarginContainer/resources/PanelContainer/MarginContainer/ScrollContainer/GridContainer
@onready var itens_materials = $MarginContainer/materials/PanelContainer/MarginContainer/ScrollContainer/GridContainer


@onready var margin_container = $MarginContainer
@onready var scenes = $MarginContainer/scenes
@onready var scripts = $MarginContainer/scripts
@onready var resources = $MarginContainer/resources
@onready var materials = $MarginContainer/materials



func _ready():
	for i in $HBoxContainer.get_child_count():
		($HBoxContainer.get_child(i) as Button).pressed.connect(_button_pressed.bind(i + 1))


func load_data(data: Dictionary):
	if not itens_scene:
		await ready
	
	itens_scene.load_scenes(data.scenes)
	itens_scripts.load_scripts(data.scripts)
	itens_resources.load_resources(data.resources)
	itens_materials.load_materials(data.materials)


func _button_pressed(id):
	self.current_state = id


func _on_return_pressed():
	self.current_state = State.MENU


