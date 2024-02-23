@tool
extends MarginContainer




signal move(idx, rel)
signal erase(field)
signal name_changed(field, new_name)




var const_name: StringName:
	set(value):
		const_name = value
		$HSplit/HBox2/ConstName.text = const_name




func configure(name: StringName):
	const_name = name




func _on_btn_erase_pressed() -> void:
	emit_signal(&'erase', const_name)




func _on_btn_move_pressed(rel) -> void:
	emit_signal(&'move', get_index(), rel)




func _on_const_name_focus_exited() -> void:
	$HSplit/HBox2/ConstName.text = const_name




func _on_const_name_text_submitted(new_name: String) -> void:
	new_name = $HSplit/HBox2/ConstName.text
	if new_name[0].is_valid_int():
		new_name = "_" + new_name
	if get_edited().rename_const(get_index(), new_name):
		$HSplit/HBox2/ConstName.text = const_name




func _on_const_name_text_changed(new_text: String) -> void:
	new_text = new_text.to_upper()
	for i in new_text.length():
		if new_text[i] == " ":
			new_text[i] = "_"
		if new_text.unicode_at(i) not in (
				range( "0".unicode_at(0), "9".unicode_at(0) ) \
				+ range( "A".unicode_at(0), "Z".unicode_at(0) ) \
				+ ["_".unicode_at(0)]
		):
			new_text[i] = "#"
	new_text = new_text.replace("#", "")
	var pos = $HSplit/HBox2/ConstName.caret_column
	$HSplit/HBox2/ConstName.text = new_text
	$HSplit/HBox2/ConstName.caret_column = min(pos, new_text.length())




func get_edited() -> Enumeration:
	return get_parent_control().owner.edited
