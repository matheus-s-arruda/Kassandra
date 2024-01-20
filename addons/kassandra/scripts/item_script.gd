@tool
extends PanelContainer

@onready var icon: TextureRect = $VBoxContainer/MarginContainer/Panel/TextureRect
@onready var _name = $VBoxContainer/Label
@onready var button = $Button
@onready var remove = $Button/remove

var base_control: Control
var data: Array


func _ready():
	if data.is_empty():
		return
	
	var _path: String = data[3] + data[1].erase(0, 6)
	_name.text = data[0]
	icon.texture = base_control.get_theme_icon(data[2], "EditorIcons")
	
	var fail: bool
	if not FileAccess.file_exists(_path):
		_name.set_tooltip_text("Path not found, the file was moved or deleted. ")
		fail = true
	
	var ext: String = _path.get_extension()
	if ext != "gd":
		_name.set_tooltip_text(_name.get_tooltip_text() + "The file is not in a script format(.gd).")
		fail = true
	
	if fail:
		button.disabled = true
		_name.modulate = Color.ORANGE_RED.lightened(0.7)
		_name.add_theme_color_override("font_color", Color.RED)
