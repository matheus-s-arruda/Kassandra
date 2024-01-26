@tool
extends EditorInspectorPlugin


var obj_focus: Object:
	set(obj):
		if obj_focus and obj_focus.property_list_changed.is_connected(change_notify):
			obj_focus.property_list_changed.disconnect(change_notify)
		
		obj_focus = obj
		
		if obj_focus:
			obj_focus.property_list_changed.connect(change_notify)

var plugin: EditorPlugin


func _can_handle(object):
	if object is Resource and plugin.get_editor_interface().get_inspector().get_edited_object() != object:
		plugin.get_editor_interface().edit_resource(object)
	
	obj_focus = object
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: PropertyUsageFlags, wide: bool):
	# We handle properties of type integer.
	if type == TYPE_INT:
		# Create an instance of the custom property editor and register
		# it to a specific property path.
		# Inform the editor to remove the default property editor for
		# this property type.
		return true
	else:
		return false


func change_notify(what: String = "\" \""):
	print(what)
