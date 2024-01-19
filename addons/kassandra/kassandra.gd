@tool
extends EditorPlugin

const SAVE_TEMPLATE := {
	"scenes": {}, "scripts": {}, "resources": {}, "mateirals": {}, "meshes": {}, "plugins": {}
}
const SAVE_DATA_PATH := "kassandra.data"
const KASSANDRA_POPUP_ID := 6
const KASSANDRA_POPUP_INDEX := 13

var editor_interface: EditorInterface
var scene_popup: PopupMenu
var scene_tabbar: TabBar
var main_panel: Control

var project_global_path: String = ProjectSettings.globalize_path("res://")
var config_direction: String
var data: Dictionary = SAVE_TEMPLATE.duplicate(true)


func _enter_tree():
	editor_interface = get_editor_interface()
	config_direction = editor_interface.get_editor_paths().get_config_dir()
	load_data()
	
	main_panel = preload("res://addons/kassandra/scenes/editor.tscn").instantiate()
	main_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	main_panel.plugin = self
	main_panel.load_data(data)
	
	editor_interface.get_editor_main_screen().add_child(main_panel)
	_make_visible(false)
	
	scene_tabbar = editor_interface.get_editor_main_screen().get_parent().get_parent().get_child(0).get_child(0).get_child(0).get_child(0)
	scene_popup = editor_interface.get_editor_main_screen().get_parent().get_parent().get_child(0).get_child(0).get_child(0).get_child(1)
	scene_popup.index_pressed.connect(_scene_popup_pressed)
	scene_popup.visibility_changed.connect(_scene_popup)


func _scene_popup():
	if scene_popup.visible:
		scene_popup.add_item("Save on Kassandra", KASSANDRA_POPUP_ID)
		scene_popup.set_item_icon(scene_popup.get_item_index(KASSANDRA_POPUP_ID), preload("res://addons/kassandra/assets/kassandra_icon.svg"))


func _scene_popup_pressed(index: int):
	if index == KASSANDRA_POPUP_INDEX:
		var scene_name = scene_tabbar.get_tab_title(scene_tabbar.current_tab)
		var scene_path: String = editor_interface.get_open_scenes()[scene_tabbar.current_tab]
		#scene_path = project_global_path + scene_path.erase(0, 6)
		
		var type: int #"Node", "Control", "2D", "3D"
		var node = get_tree().edited_scene_root
		if node is Node3D:
			type = 3
		elif node is Node2D:
			type = 2
		elif node is Control:
			type = 1
		else:
			type = 0
			
		var id := uuid()
		while data.has(id):
			id = uuid()
		
		data.scenes[id] = [scene_name, scene_path, type, project_global_path]
		
		save_data()
		main_panel.load_data(data)


func _exit_tree():
	if is_instance_valid(main_panel):
		main_panel.queue_free()
	
	scene_popup.index_pressed.disconnect(_scene_popup_pressed)
	scene_popup.visibility_changed.disconnect(_scene_popup)


#region MAIN PANEL
func _has_main_screen():
	return true

func _make_visible(visible: bool):
	if main_panel:
		load_data()
		main_panel.load_data(data)
		main_panel.visible = visible

func _get_plugin_name():
	return "Kassandra"

func _get_plugin_icon():
	return preload("res://addons/kassandra/assets/kassandra_icon.svg")
#endregion

#region SAVE & LOAD
func save_data():
	var file := FileAccess.open(config_direction + SAVE_DATA_PATH, FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()


func load_data():
	var file = FileAccess.open(config_direction + SAVE_DATA_PATH, FileAccess.READ)
	if not file:
		save_data()
	else:
		var new_stg = file.get_var()
		file.close()
		if new_stg is Dictionary:
			data = new_stg
		else:
			save_data()
#endregion

func uuid() -> String:
	return "%02x%02x-%02x%02x-%02x%02x-%02x%02x" % [
		randi() & 0b11111111, randi() & 0b11111111, randi() & 0b11111111,
		randi() & 0b11111111, randi() & 0b11111111, randi() & 0b11111111,
		((randi() & 0b11111111) & 0x0f) | 0x40, 	randi() & 0b11111111
	]