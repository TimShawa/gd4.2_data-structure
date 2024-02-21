@tool
extends MarginContainer


signal move(idx, rel)
signal change_type(field, type)
signal erase(field)
signal name_changed(field, new_name)

var field_name: StringName:
	set(value):
		field_name = value
		$HSplit/HBox2/FieldName.text = field_name


var type: Variant.Type:
	set(value):
		if value in [ TYPE_RID, TYPE_SIGNAL, TYPE_CALLABLE ]:
			value = TYPE_NIL
		if value < 0 or value >= TYPE_MAX:
			value = TYPE_NIL
		if value in range(TYPE_ARRAY + 1, TYPE_PACKED_COLOR_ARRAY + 1):
			value = TYPE_ARRAY
		type = value



func configure(field, type):
	field_name = field
	self.type = type
	$HSplit/HBox/BtnType.selected = type




func _on_btn_type_item_selected(index: int) -> void:
	type = $HSplit/HBox/BtnType.get_item_id(index)
	emit_signal(&'change_type', field_name, type)




func _on_btn_erase_pressed() -> void:
	emit_signal(&'erase', field_name)


func _on_btn_move_pressed(rel) -> void:
	emit_signal(&'move', get_index(), rel)


func _on_field_name_focus_exited() -> void:
	$HSplit/HBox2/FieldName.text = field_name


func _on_field_name_text_submitted(new_name: String) -> void:
	if StructureBase.is_valid_field_name(new_name):
		var old_name = field_name
		field_name = new_name
		emit_signal(&'name_changed', old_name, new_name)
	else:
		$HSplit/HBox2/FieldName.text = field_name
