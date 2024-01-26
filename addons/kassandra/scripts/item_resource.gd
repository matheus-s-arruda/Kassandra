@tool
extends PanelContainer

@onready var icon: TextureRect = $VBoxContainer/MarginContainer/Panel/TextureRect
@onready var _name = $VBoxContainer/Label
@onready var drag_previel = $VBoxContainer/MarginContainer/Panel
@onready var drag_area = $drag_area
@onready var remove = $drag_area/remove

var fail: bool
var data: Array
var _path: String

var editor: Control
var base_control: Control


func _ready():
	if data.is_empty():
		return
	
	var _texture: ImageTexture = base_control.get_theme_icon(data[2], "EditorIcons")
	icon.texture = _texture
	
	_path = data[3] + data[1].erase(0, 6)
	_name.text = (data[0] as String).replace(".gd", "")
	
	if not FileAccess.file_exists(_path):
		_name.set_tooltip_text("Path not found, the file was moved or deleted. ")
		fail = true
		
	if fail:
		_name.modulate = Color.ORANGE_RED.lightened(0.7)
		_name.add_theme_color_override("font_color", Color.RED)
		return
	
	set_tooltip_text(_path)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_double_click():
		var filedialog = FileDialog.new()
		add_child(filedialog)
		filedialog.popup_centered()
		filedialog.size = Vector2(500, 300)
		filedialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		
		var dir_selected := ["", ""]
		filedialog.dir_selected.connect(func(path: String): dir_selected[0] = path; dir_selected[1] = filedialog.get_line_edit().text)
		filedialog.confirmed.connect(install_resouce.bind(_path, dir_selected))
		filedialog.canceled.connect(func(): filedialog.queue_free())
		filedialog.show()


func install_resouce(_path: String, dir_selected):
	var read_file = FileAccess.open(_path, FileAccess.READ)
	var target_path: String = dir_selected[0]
	
	if read_file:
		if target_path[-1] != "/":
			target_path += "/"
		
		if dir_selected[1].is_empty():
			target_path += _path.get_file()
		else:
			target_path += dir_selected[1] + _path.get_extension()
		
		var white_file = FileAccess.open(target_path, FileAccess.WRITE)
		if white_file:
			var content: String = read_file.get_as_text()
			white_file.store_string(content)
			white_file.close()


func _get_drag_data(_p):
	if fail:
		return null

	var preview := drag_previel.duplicate()
	preview.modulate.a = 0.66
	
	set_drag_preview(preview)
	return {"type": "files", "files": load("res://addons/kassandra/scripts/temp.gd")}
