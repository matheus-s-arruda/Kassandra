@tool
extends PanelContainer

@onready var icon: TextureRect = $VBoxContainer/MarginContainer/Panel/TextureRect
@onready var _name = $VBoxContainer/Label
@onready var drag_previel = $VBoxContainer/MarginContainer/Panel
@onready var drag_area = $drag_area
@onready var remove = $drag_area/remove

var timer_flag_click := 0.0
var flag_click: bool
var flag_click_reliase: bool

@onready var p := EditorPlugin.new()
@onready var scene_tree_editor: Control = p.get_editor_interface().get_base_control().get_child(0).get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_child(3)
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
	
	scene_tree_editor.connect("script_dropped", drop_script, CONNECT_ONE_SHOT)
	
	load_and_save_script()
	p.get_editor_interface().edit_script(load("res://addons/kassandra/scripts/temp.gd"))
	script_editor_base = p.get_editor_interface().get_script_editor().get_current_editor()
	
	set_drag_preview(preview)
	return {"type": "script_list_element", "script_list_element": script_editor_base}


func drop_script(a: String, b: NodePath):
	var node: Node = script_editor_base.get_node(b)
	node.set_script(null)
	
	var filedialog = FileDialog.new()
	add_child(filedialog)
	filedialog.popup_centered()
	filedialog.size = Vector2(500, 300)
	filedialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	
	var dir_selected := ["", ""]
	filedialog.dir_selected.connect(func(path: String): dir_selected[0] = path; dir_selected[1] = filedialog.get_line_edit().text)
	filedialog.confirmed.connect(install_script2.bind(_path, dir_selected, node))
	filedialog.canceled.connect(func(): filedialog.queue_free())
	filedialog.show()


func install_script2(_path: String, dir_selected, node: Node):
	print("install_script2")
	var script = install_script(_path, dir_selected)
	node.set_script(script)


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
		flag_click_reliase = false
		flag_click = false


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.is_released():
		flag_click_reliase = true
	
	if event is InputEventMouseButton and event.is_pressed():
		if flag_click and flag_click_reliase:
			timer_flag_click = 0.0
			flag_click = false
			flag_click_reliase = false
			
			var filedialog = FileDialog.new()
			add_child(filedialog)
			filedialog.popup_centered()
			filedialog.size = Vector2(500, 300)
			filedialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
			
			var dir_selected := ["", ""]
			filedialog.dir_selected.connect(func(path: String): dir_selected[0] = path; dir_selected[1] = filedialog.get_line_edit().text)
			filedialog.confirmed.connect(install_script.bind(_path, dir_selected))
			filedialog.canceled.connect(func(): filedialog.queue_free())
			filedialog.show()
			
		else:
			timer_flag_click = 1.0
			flag_click = true


func install_script(_path: String, dir_selected):
	var read_file = FileAccess.open(_path, FileAccess.READ)
	var target_path: String = dir_selected[0]
	
	if read_file:
		if target_path[-1] != "/":
			target_path += "/"
		
		if dir_selected[1].is_empty():
			target_path += _path.get_file()
		else:
			target_path += dir_selected[1] + ".gd"
		
		var white_file = FileAccess.open(target_path, FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)
			white_file.close()
			
			var script: Script = load(target_path)
			p.get_editor_interface().edit_script(script)
			p.get_editor_interface().set_main_screen_editor("Script")
			print("sucess")
			return script
		else:
			print("fail 1")
	else:
		print("fail 2")
	
	print("fail 3")



