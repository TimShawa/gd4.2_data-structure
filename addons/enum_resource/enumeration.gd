@tool
extends Resource
class_name Enumeration




var _constants: Array[StringName] = []




func _init(enumerators: String = ""):
	if enumerators:
		( enumerators.split(",", false, 256) as Array ).map(add_const)
	connect(&"changed", notify_property_list_changed)




func _get_property_list() -> Array:
	var list = []
	list.push_back({
		name = &"_constants",
		type = TYPE_ARRAY,
		usage = PROPERTY_USAGE_STORAGE,
	})
	return list




func _validate_property(property: Dictionary) -> void:
	if property.name == "Enum ":
		if resource_path:
			property.name = "Enum " + resource_path.split("/")[-1]




func _get(prop: StringName):
	if prop in _constants:
		return _constants.find(prop)


func duplicate(deep = false):
	return Enumeration.new(",".join(_constants))




func rename_const(idx: int, new_name: String) -> Error:
	if idx < 0 or idx >= size():
		return ERR_DOES_NOT_EXIST
	if not new_name.is_valid_identifier():
		return ERR_INVALID_PARAMETER
	if new_name in _constants:
		return ERR_ALREADY_IN_USE
	_constants[idx] = new_name
	emit_changed()
	printt(idx, new_name, _constants)
	return OK


func add_const(name: StringName) -> Error:
	if _constants.size() >= 256:
		return ERR_OUT_OF_MEMORY
	if name not in _constants:
		if !name.is_valid_identifier() \
				or name == &"_constants":
			return ERR_INVALID_PARAMETER
		_constants.push_back(name)
		emit_changed()
		return OK
	return ERR_ALREADY_EXISTS




func remove_const(name: StringName) -> Error:
	if name not in _constants:
		return ERR_DOES_NOT_EXIST
	_constants.erase(name)
	emit_changed()
	return OK




func has(what: StringName):
	return what in _constants




func is_empty():
	return _constants.is_empty()


func get_instance():
	pass




func get_literal(idx):
	return _constants[idx]




func size():
	return _constants.size()
