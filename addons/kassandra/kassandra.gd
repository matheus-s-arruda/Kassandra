@tool
extends EditorPlugin

const SAVE_TEMPLATE := {
	"scenes": {}, "scripts": {}, "resources": {}, "materials": {}, "meshes": {}, "plugins": {}
}
const SAVE_DATA_PATH := "kassandra.data"
const KASSANDRA_POPUP_ID := 666
const KASSANDRA_POPUP_INDEX := 13

var editor_interface: EditorInterface
var scripts_popup2: PopupMenu
var scripts_popup: PopupMenu
var base_control: Control
var scene_tabbar: TabBar
var scene_popup: PopupMenu
var main_panel: Control

var inspector_save_popup: PopupMenu

var project_global_path: String = ProjectSettings.globalize_path("res://")
var config_direction: String
var data: Dictionary = SAVE_TEMPLATE.duplicate(true)

func _enter_tree():
	editor_interface = get_editor_interface()
	config_direction = editor_interface.get_editor_paths().get_config_dir()
	base_control = get_editor_interface().get_base_control()
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
	
	scripts_popup = editor_interface.get_script_editor().get_child(0).get_child(0).get_child(0).get_popup()
	scripts_popup.add_item("", 66)
	scripts_popup.set_item_as_separator(scripts_popup.get_item_index(66), true)
	scripts_popup.add_item("Save on Kassandra", KASSANDRA_POPUP_ID)
	scripts_popup.set_item_icon(scripts_popup.get_item_index(KASSANDRA_POPUP_ID), preload("res://addons/kassandra/assets/kassandra_icon.svg"))
	scripts_popup.index_pressed.connect(_script_popup_pressed)
	
	scripts_popup2 = editor_interface.get_script_editor().get_child(1)
	scripts_popup2.visibility_changed.connect(_scripts_popup)
	scripts_popup2.index_pressed.connect(_script_popup_pressed)
	
	inspector_save_popup = editor_interface.get_inspector().get_parent().get_child(0).get_child(2).get_popup()
	inspector_save_popup.add_icon_item(preload("res://addons/kassandra/assets/kassandra_icon.svg"), "Save on Kassandra", KASSANDRA_POPUP_ID)
	inspector_save_popup.index_pressed.connect(_resource_popup_pressed)


func _exit_tree():
	if is_instance_valid(main_panel):
		main_panel.queue_free()
	
	scripts_popup.remove_item(scripts_popup.get_index(KASSANDRA_POPUP_ID))
	scene_popup.index_pressed.disconnect(_scene_popup_pressed)
	scene_popup.visibility_changed.disconnect(_scene_popup)
	inspector_save_popup.remove_item(inspector_save_popup.get_index(KASSANDRA_POPUP_ID))


func _scene_popup():
	if scene_popup.visible:
		scene_popup.add_item("", 66)
		scene_popup.set_item_as_separator(scene_popup.get_item_index(66), true)
		scene_popup.add_item("Save on Kassandra", KASSANDRA_POPUP_ID)
		scene_popup.set_item_icon(scene_popup.get_item_index(KASSANDRA_POPUP_ID), preload("res://addons/kassandra/assets/kassandra_icon.svg"))


func _scene_popup_pressed(index: int):
	if scene_popup.get_item_index(KASSANDRA_POPUP_ID):
		var scene_name = scene_tabbar.get_tab_title(scene_tabbar.current_tab)
		var scene_path: String = editor_interface.get_open_scenes()[scene_tabbar.current_tab]
		
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
			
		var id := KassandraBook.uuid()
		while data.scenes.has(id):
			id = KassandraBook.uuid()
		
		data.scenes[id] = [scene_name, scene_path, type, project_global_path]
		
		save_data()
		main_panel.load_data(data)


func _scripts_popup():
	if scripts_popup2.visible:
		scripts_popup2.add_item("", 66)
		scripts_popup2.set_item_as_separator(scripts_popup2.get_item_index(66), true)
		scripts_popup2.add_item("Save on Kassandra", KASSANDRA_POPUP_ID)
		scripts_popup2.set_item_icon(scripts_popup2.get_item_index(KASSANDRA_POPUP_ID), preload("res://addons/kassandra/assets/kassandra_icon.svg"))


func _script_popup_pressed(index: int):
	if scripts_popup.get_item_id(index) == KASSANDRA_POPUP_ID or scripts_popup2.get_item_id(index) == KASSANDRA_POPUP_ID:
		var id := KassandraBook.uuid()
		while data.scripts.has(id):
			id = KassandraBook.uuid()
		
		var script: Script = editor_interface.get_script_editor().get_current_script()
		data.scripts[id] = [script.resource_path.get_file(), script.resource_path, script.get_instance_base_type(), project_global_path]
		
		save_data()
		main_panel.load_data(data)


func _resource_popup_pressed(index: int):
	if index == inspector_save_popup.get_item_index(KASSANDRA_POPUP_ID):
		var obj: Resource = editor_interface.get_inspector().get_edited_object()
		if obj.resource_path.is_empty():
			var alert := AcceptDialog.new()
			main_panel.add_child(alert)
			
			alert.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
			alert.exclusive = true
			alert.dialog_text = "Resource not saved to disk, please save the resource to file and try again."
			alert.show()
			
			# BUG editor/inspector_dock.cpp:215 - Index idx = 166 is out of bounds (methods.size() = 145). https://github.com/godotengine/godot/issues/84522
			return
		
		var id := KassandraBook.uuid()
		while data.scripts.has(id):
			id = KassandraBook.uuid()
		
		var _name: String = obj.resource_path.get_file().replace(".tres", "").replace(".res", "")
		
		if obj is Material:
			data.materials[id] = [_name, obj.resource_path, obj.get_class(), project_global_path]
		
		elif obj is Mesh:
			data.meshes[id] = [_name, obj.resource_path, project_global_path]
		
		else:
			data.resources[id] = [_name, obj.resource_path, obj.get_class(), project_global_path]
		
		save_data()
		main_panel.load_data(data)


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

