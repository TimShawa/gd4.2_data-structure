@tool
extends VBoxContainer


const SCENES = {
	const_defintion = preload("res://addons/enum_resource/insp_editor_enum/const_defintion.scn")
}

var edited: Enumeration




func update() -> void:
	var list = %Consts.get_children()
	for i in list:
		i.queue_free()
	for con in edited._constants:
		var entry = SCENES.const_defintion.instantiate()
		%Consts.add_child(entry)
		entry.configure(con)
		entry.connect(&'erase', edited.remove_const)
		entry.connect(&'move', move_const)
		entry.connect(&'name_changed', edited.rename_const)
	$ScrollContainer.visible = %Consts.get_child_count()
	$HSeparator5.visible = %Consts.get_child_count()




func _on_btn_new_pressed() -> void:
	if &"NEW_ENUMERATOR" not in edited:
		edited.add_const(&"NEW_ENUMERATOR")
	else:
		push_warning("Cannot create a new constant if there is one with default name (\"NEW_ENUMERATOR\")")




func move_const(idx, offset):
	var original = edited.get_literal(idx)
	match offset:
		-1:
			if idx <= 0:
				return
		1:
			if idx >= edited.size() - 1:
				return
	var new = edited.literals()[idx + offset]
	edited._constants[idx] = new
	edited._constants[idx + offset] = original
	edited.emit_changed()
