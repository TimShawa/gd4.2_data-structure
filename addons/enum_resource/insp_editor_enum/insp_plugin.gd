@tool
extends EditorInspectorPlugin




const PROPERTY = preload("res://addons/enum_resource/insp_editor_enum/enum_editor.scn")
const Enum = preload("res://addons/enum_resource/enumeration.gd")




func _can_handle(object: Object) -> bool:
	return true




func _parse_begin(object: Object) -> void:
	if object is Enum:
		var editor = PROPERTY.instantiate()
		add_custom_control(editor)
		editor.edited = object
		object.connect(&"changed", editor.update)
		editor.update()




func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide) -> bool:
	if not (object is Enum):
		if object.get(name) is Enum: pass
	return false
