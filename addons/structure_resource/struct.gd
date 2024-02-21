@tool
extends Resource
class_name struct


#region Properties

var __base_path__: String = ""
var __base__: StructureBase
var __data__: Dictionary = {}
var __configured__: bool = false




func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = [
		{
			name = &"path to base",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT if !_is_base_internal() else (PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY),
			hint = PROPERTY_HINT_FILE,
			hint_string = "*.res,*.tres"
		},
		{
			name = "Values ",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP
		}
	]
	
	for field in __data__:
		list.push_back({
			name = field,
			type = __base__.signature[field].type,
			usage = __base__.signature[field].usage,
			hint = __base__.signature[field].hint,
			hint_string = __base__.signature[field].hint_string
		})
	
	return list


func _get(property: StringName):
	if property == &"path to base":
		return __base_path__


func _set(property: StringName, value: Variant) -> bool:
	if property == &"path to base":
		if !value == &"<internal>":
			var base = load(value)
			if is_instance_valid(base):
				__base_path__ = value
				__base__ = base
				return true
		__base_path__ = value
		return true
	return false


func _property_can_revert(property: StringName) -> bool:
	if property == &"path to base":
		return !_is_base_internal()
	if property in __data__:
		return __data__[property] != __base__.default_values[property]
	return false


func _property_get_revert(property: StringName):
	if property in __base__.default_values:
		return __base__.default_values[property]


#endregion



## Loads base from [param on_base] path and create new [struct] on it.
static func fetch(on_base: String) -> struct:
	var base = load(on_base)
	if !is_instance_valid(base):
		return null
	return struct.new(base)


## Creates new [struct]. Parameter [param base] defines its field configuration.
func _init(base: StructureBase):
	if base.is_empty():
		push_error(error_string(ERR_UNCONFIGURED))
		return
	if base.resource_path.split(":", 0).size() == 1:
		set(&"path to base", base.resource_path)
	else:
		set(&"path to base", "<internal>")
	__base__ = base
	__data__ = __base__.default_values.duplicate(1)
	
	#region Connect Signals
	connect(&"changed", func(s=self): s.emit_signal(&"property_list_changed"))
	#endregion
	
	emit_changed()



## Returns array of structure field names (read-only). See also [method values].
func fields() -> Array[StringName]:
	var r_value: Array[StringName] = []
	for field: StringName in __data__.keys():
		r_value.push_back(field)
	r_value.make_read_only()
	return r_value


## Returns array of structure values (read-only). See also [method fields].
func values() -> Array:
	var r_value = __data__.values().duplicate()
	r_value.make_read_only()
	return r_value




func _is_base_internal() -> bool:
	return __base_path__ == "<internal>"




func modify(map: Dictionary):
	for field in map:
		if field in __data__:
			if field in __base__.signature:
				if __base__.is_value_compatible(field, map[field]):
					__data__[field] = map[field]
	emit_changed()
