@tool
extends VBoxContainer

const ITEM_SCENE = preload("res://addons/kassandra/scenes/item_scene.tscn")

@onready var editor = $"../../../../../.."


func load_scenes(scenes: Dictionary):
	get_children().map(func(c): c.queue_free())
	await get_tree().process_frame
	
	for scene in scenes:
		var item = create_item(scenes[scene])
		item.install.pressed.connect(editor.install_scene.bind(scene))
		item.remove.pressed.connect(editor.remove_scene.bind(scene))


func create_item(data: Array):
	var item := ITEM_SCENE.instantiate()
	item.data = data
	add_child(item)
	return item
