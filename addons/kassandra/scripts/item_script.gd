@tool
extends PanelContainer

@onready var icon: TextureRect = $VBoxContainer/MarginContainer/Panel/TextureRect
@onready var _name = $VBoxContainer/Label
@onready var drag_previel = $VBoxContainer/MarginContainer/Panel
@onready var drag_area = $drag_area
@onready var remove = $drag_area/remove

var timer_flag_click := 0.0
var flag_click: bool

@onready var p := EditorPlugin.new()
var script_editor_base: ScriptEditorBase

var editor: Control
var _path: String
var base_control: Control
var data: Array
var fail: bool

func _ready():
	if data.is_empty():
		return
	
	var _texture: ImageTexture = base_control.get_theme_icon(data[2], "EditorIcons")
	icon.texture = _texture
	
	_path = data[3] + data[1].erase(0, 6)
	_name.text = data[0]
	
	if not FileAccess.file_exists(_path):
		_name.set_tooltip_text("Path not found, the file was moved or deleted. ")
		fail = true
	
	var ext: String = _path.get_extension()
	if ext != "gd":
		_name.set_tooltip_text(_name.get_tooltip_text() + "The file is not in a script format(.gd).")
		fail = true
	
	if fail:
		_name.modulate = Color.ORANGE_RED.lightened(0.7)
		_name.add_theme_color_override("font_color", Color.RED)
		return
	
	set_tooltip_text(_path)


func _get_drag_data(_p):
	if fail:
		return null

	var preview := drag_previel.duplicate()
	preview.modulate.a = 0.66
	
	load_and_save_script()
	p.get_editor_interface().edit_script(load(data[1]))
	script_editor_base = p.get_editor_interface().get_script_editor().get_current_editor()
	
	set_drag_preview(preview)
	return {"type": "script_list_element", "script_list_element": script_editor_base}


func load_and_save_script():
	var read_file = FileAccess.open(_path, FileAccess.READ)
	if read_file:
		var white_file = FileAccess.open(data[1], FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)
			white_file.close()
		read_file.close()


func _process(delta):
	if timer_flag_click > 0.0:
		timer_flag_click -= delta
	else:
		flag_click = false


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if flag_click:
			timer_flag_click = 0.0
			flag_click = false
			
			if editor.copy_and_save(_path, data[1]):
				p.get_editor_interface().edit_script(load(data[1]))
				p.get_editor_interface().set_main_screen_editor("Script")
		
		else:
			timer_flag_click = 1.0
			flag_click = true
