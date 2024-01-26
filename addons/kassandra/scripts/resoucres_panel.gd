@tool
extends HFlowContainer

const ITEM_RESOURCE = preload("res://addons/kassandra/scenes/item_resource.tscn")


@onready var editor = $"../../../../../.."


func load_resources(resources: Dictionary):
	get_children().map(func(c): c.queue_free())
	await get_tree().process_frame
	
	for resource in resources:
		var item = create_item(resources[resource])
		item.remove.pressed.connect(remove_resource.bind(resource))


func create_item(data: Array):
	var item := ITEM_RESOURCE.instantiate()
	item.base_control = editor.plugin.base_control
	item.editor = editor
	item.data = data
	add_child(item)
	return item


func remove_resource(id: String):
	var confirm_remove := ConfirmationDialog.new()
	add_child(confirm_remove)
	
	confirm_remove.exclusive = true
	confirm_remove.title = "Remove this item?"
	confirm_remove.dialog_text = "Caution! This action is irreversible."
	confirm_remove.popup_centered()
	
	confirm_remove.confirmed.connect(
		func():
			editor.plugin.data.resources.erase(id)
			editor.plugin.save_data()
			editor.load_data.call_deferred(editor.plugin.data)
	)
	confirm_remove.canceled.connect(func(): confirm_remove.queue_free())
	confirm_remove.show()
