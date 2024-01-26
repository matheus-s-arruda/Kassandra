@tool
extends HFlowContainer


const ITEM_MATERIAL = preload("res://addons/kassandra/scenes/item_material.tscn")


@onready var editor = $"../../../../../.."


func load_materials(materials: Dictionary):
	get_children().map(func(c): c.queue_free())
	await get_tree().process_frame
	
	for _material in materials:
		var item = create_item(materials[_material])
		item.remove.pressed.connect(remove_materials.bind(_material))


func create_item(data: Array):
	var item := ITEM_MATERIAL.instantiate()
	item.base_control = editor.plugin.base_control
	item.editor = editor
	item.data = data
	add_child(item)
	return item


func remove_materials(id: String):
	var confirm_remove := ConfirmationDialog.new()
	add_child(confirm_remove)
	
	confirm_remove.exclusive = true
	confirm_remove.title = "Remove this item?"
	confirm_remove.dialog_text = "Caution! This action is irreversible."
	confirm_remove.popup_centered()
	
	confirm_remove.confirmed.connect(
		func():
			editor.plugin.data.materials.erase(id)
			editor.plugin.save_data()
			editor.load_data.call_deferred(editor.plugin.data)
	)
	confirm_remove.canceled.connect(func(): confirm_remove.queue_free())
	confirm_remove.show()
