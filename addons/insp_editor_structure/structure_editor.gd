@tool
extends VBoxContainer


const SCENES = {
	field_defintion = preload('res://addons/structure_resource/insp_editor_structure/field_defintion.scn')
}

var edited: StructureBase




func update() -> void:
	var list = %Fields.get_children()
	for i in list:
		i.queue_free()
	for field in edited.signature:
		var entry = SCENES.field_defintion.instantiate()
		%Fields.add_child(entry)
		entry.configure(field, edited.signature[field].type)
		entry.connect(&'erase', edited.erase_field)
		entry.connect(&'move', edited.move_field)
		entry.connect(&'name_changed', edited.rename_field)
		entry.connect(&'change_type', edited.change_field_type)




func _on_btn_new_pressed() -> void:
	var new_field = edited.create_field()
	for i in %Fields.get_children():
		if i.field_name == new_field:
			i.find_child('FieldName').grab_focus()
			break
