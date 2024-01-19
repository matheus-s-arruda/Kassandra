@tool
extends HBoxContainer

@onready var _name = $name
@onready var path = $path
@onready var type = $Label
@onready var install = $install
@onready var remove = $remove

var data: Array


func _ready():
	if data.is_empty():
		return
	
	var _type: int = data[2]
	_name.text = data[0]
	path.text = data[1]
	type.text = ["Node", "Control", "2D", "3D"][_type]
	type.add_theme_color_override("font_color", [Color("8a8a8a"), Color("8eef97"), Color("879fe9"), Color("fc7f7f")][_type])
	
	var fail: bool
	if not FileAccess.file_exists(data[1]):
		path.set_tooltip_text("Path not found, the file was moved or deleted. ")
		fail = true
	
	var ext: String = data[1].get_extension()
	if (ext != "tscn" and ext != "scn" and ext != "res"):
		
		path.set_tooltip_text(path.get_tooltip_text() + "File format not understood by the editor. ")
		fail = true
	
	if fail:
		install.disabled = true
		path.modulate = Color.ORANGE_RED.lightened(0.7)
		path.add_theme_color_override("font_color", Color.RED)



