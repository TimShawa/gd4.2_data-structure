@tool
extends Window


var struct: WeakRef
var field: StringName


@export var c_field_name: LineEdit
@export var c_type_option: OptionButton
@export var c_type_switch: TabContainer
@export var c_is_resource: CheckBox
@export var c_res_type: LineEdit
@export var c_enumerate: CheckButton
@export var c_enumerators: LineEdit
@export var c_btn_load_enum: Button




func configure(struct: StructureBase, field: StringName):
	self.struct = weakref(struct)
	self.field = field
	struct.connect(&"changed", update)
	update()




func _on_close_requested() -> void:
	hide()
	queue_free()




func update():
	var type: Variant.Type = struct.get_ref().signature[field].type
	var hint: PropertyHint = struct.get_ref().signature[field].hint
	var hint_string: String = struct.get_ref().signature[field].hint_string
	
	c_field_name.text = field
	c_type_option.selected = c_type_option.get_item_index(type)
	c_type_switch.current_tab = 0
	
	if type == TYPE_OBJECT:
		c_type_switch.current_tab = 1
		c_is_resource.button_pressed = hint == PROPERTY_HINT_RESOURCE_TYPE
		c_res_type.get_parent_control().visible = c_is_resource.button_pressed
		c_res_type.text = hint_string
	
	if type in [ TYPE_INT, TYPE_STRING, TYPE_STRING_NAME ]:
		c_type_switch.current_tab = 2
		if hint in [ PROPERTY_HINT_ENUM, PROPERTY_HINT_ENUM_SUGGESTION ]:
			c_enumerators.text = hint_string
			c_enumerators.get_parent_control().get_parent_control().visible = true
			c_enumerate.button_pressed = true
			
		else:
			c_enumerators.get_parent_control().get_parent_control().visible = false
			c_enumerate.button_pressed = false




func _on_enumerate_toggled(toggled_on: bool) -> void:
	var type: Variant.Type = struct.get_ref().signature[field].type
	var hint: PropertyHint = struct.get_ref().signature[field].hint
	if type in [ TYPE_INT, TYPE_STRING, TYPE_STRING_NAME ]:
		if toggled_on:
			struct.get_ref().signature[field].hint = PROPERTY_HINT_ENUM
		else:
			if hint == PROPERTY_HINT_ENUM:
				struct.get_ref().signature[field].hint = PROPERTY_HINT_NONE
	struct.get_ref().emit_changed()




func _on_constants_text_submitted(new_text: String) -> void:
	var type = struct.get_ref().signature[field].type
	if type in [ TYPE_INT, TYPE_STRING, TYPE_STRING_NAME ]:
		if c_enumerate.button_pressed:
			struct.get_ref().signature[field].hint_string = c_enumerators.text
	struct.get_ref().emit_changed()




func _on_field_name_text_submitted(new_name: String) -> void:
	if StructureBase.is_valid_field_name(new_name):
		var old_name = field
		field = new_name
		struct.get_ref().rename_field(old_name, new_name)
	else:
		c_field_name.text = field


func _on_btn_load_enum_pressed() -> void:
	var dial := EditorFileDialog.new()
	dial.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dial.connect(&"file_selected",
		func(f, struct = struct.get_ref() as StructureBase):
			if dial.current_path:
				var file = load(dial.current_path)
				print(file)
				struct.signature[field].hint_string = ",".join(file._constants)
				struct.emit_changed()
	)
	add_child(dial)
	dial.popup_centered_ratio(0.6)
	await dial.visibility_changed
	dial.hide()
	dial.queue_free()


func _on_type_option_item_selected(index: int) -> void:
	struct.get_ref().signature[field].type = c_type_option.get_item_id(index)
	struct.get_ref().emit_changed()
