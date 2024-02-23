@tool
@icon("res://addons/structure_resource/icon_structure_base.svg")
extends Resource
class_name StructureBase


## @experimental
## Base of [Struct] for its configuration.
##
## Usage description will be added as soon as possible.




#endregion

#region Variables

## A structure's scheme difining its members and how they operate with [Variants].
var signature: Dictionary = {}
## Mapping of default fields' values.
var default_values: Dictionary = {}

#endregion





func _init(map: Dictionary = {}) -> void:
	#region BUILD STRUCTURE
	if map.is_empty():
		#push_warning(get_struct_id() + ": Structure base is empty. Add some fields with StructureBase.create_field() or it might cause errors.")
		pass
	else:
		signature.clear()
		for field in map:
			#region HANDLE EXCEPTIONS
			if !is_valid_field_name(field):
				push_warning("StructureBase: Trying to create field with invalid name ({f}). Ignored.".format([field]))
				continue
			if field in signature:
				push_warning("StructureBase: Field [{f}] is already inside. Ignored.".format([field]))
				continue
			if &"type" not in map[field]:
				push_warning("StructureBase: Field [{f}] has unset type. Ignored.".format([field]))
				continue
			#endregion
			
			signature[field] = { type = map[field].type }
			
			if map[field].has(&"usage"):
				signature[field].usage = map[field].usage
			else:
				signature[field].usage = PROPERTY_USAGE_DEFAULT
			
			if map[field].has(&"hint"):
				signature[field].hint = map[field].hint
			else:
				signature[field].hint = PROPERTY_HINT_NONE
			
			if map[field].has(&"hint_string"):
				signature[field].hint_string = map[field].hint_string
			else:
				signature[field].hint_string = ""
			
			if map[field].has(&"default"):
				default_values[field] = map[field].default
			else:
				default_values[field] = type_default_value(map[field].type)
	#endregion
	
	connect(&"changed", refresh_defaults)
	connect(&"changed", notify_property_list_changed)
	
	notify_property_list_changed()




#region Properties


func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if resource_path.trim_prefix("res://").split(":", 0).size() == 1:
		list.push_back({
			name = "Default Values",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP
		})
		if signature.is_empty():
			list.append({
				name = "Empty",
				type = TYPE_NIL,
				usage = PROPERTY_USAGE_EDITOR
			})
		else:
			for field in default_values:
				var entry = {
					name = field + " ",
					type = signature[field].type
				}
				if &"usage" in signature[field]:
					entry.usage = signature[field].usage
				if &"hint" in signature[field]:
					entry.hint = signature[field].hint
					if &"hint_string" in signature[field]:
						entry.hint_string = signature[field].hint_string
				list.push_back(entry)
		list.push_front({name="Structure",type=TYPE_NIL,usage=PROPERTY_USAGE_EDITOR|PROPERTY_USAGE_GROUP})
	return list




func _get(prop: StringName):
	if prop.ends_with(" "):
		prop = prop.trim_suffix(" ")
		if prop in default_values:
			return default_values[prop]
	if prop == &"instantiate":
		return true




func _set(prop: StringName, value: Variant) -> bool:
	if prop.ends_with(" "):
		prop = prop.trim_suffix(" ")
		if prop in default_values:
			default_values[prop] = value
			return true
	if prop == &"instantiate": pass
	return false


#endregion




#region Fields


## Creates new field with specified [param name], [param type], [param usage], [param hint], [param hint_string]
## and sets its default to [param default] parameter value, if it's compatible with [param type].
func create_field(name: StringName = &"new_variable", type := TYPE_INT, default = 0, usage := PROPERTY_USAGE_DEFAULT, hint := PROPERTY_HINT_NONE, hint_string := "") -> StringName:
	#region HANDLE EXCEPTIONS
	if name.is_empty():
		push_warning("StructureBase: Trying to create field with empty name. Skipped.")
		return &""
	if type < 0 or type >= TYPE_MAX:
		push_warning("StructureBase: Trying to create field with invalid Variant type. Skipped.")
		return &""
	if type in [ TYPE_CALLABLE, TYPE_SIGNAL, TYPE_RID ]:
		type = TYPE_NIL
	if default != null and typeof(default) != type:
		push_warning("StructureBase: Trying to create field with invalid default value, so that value has been rejected.")
		default = type_default_value(type)
	#endregion
	
	name = unique_name(name)
	signature[name] = { type=type, usage=usage, hint=hint, hint_string=hint_string }
	if is_value_compatible(name, default):
		default_values[name] = default
	else:
		default_values[name] = type_default_value(type)
	emit_changed()
	return name




## Erases (removes from signature) the field with specified [param name].
func erase_field(name: StringName) -> bool:
	if name in signature:
		signature.erase(name)
		emit_changed()
		return true
	return false




## Moves field at specified index ([param idx]) to new location relatively ([param rel]).
func move_field(idx: int, rel: int) -> void:
	signature = dict_move_to(signature, idx, idx + rel)
	emit_changed()




## Changes [field] type to another [enum Variant.Type] constant.
func change_field_type(field: StringName, type: Variant.Type):
	if field in signature:
		signature[field].type = type
		emit_changed()




## Renames [param old] field with [param new] name.
func rename_field(old: StringName, new: StringName) -> void:
	if old in signature.keys():
		var temp = {}
		for i in signature.size():
			if signature.keys()[i] == old:
				temp[new] = signature[old]
			else:
				temp[ signature.keys()[i] ] = signature.values()[i]
		signature = temp
		
		temp = {}
		for i in signature.size():
			temp[ signature.keys()[i] ] = default_values.values()[i]
		default_values = temp
		
		emit_changed()


#endregion




## Updates [member default_values] listing all fields, adding new if created and remove missing ones. Used internally.
func refresh_defaults() -> void:
	var temp = default_values.duplicate(1)
	default_values.clear()
	for field in signature:
		if field in temp:
			if is_value_compatible(field, temp[field]):
				default_values[field] = temp[field]
				continue
		default_values[field] = type_default_value(signature[field].type)
	emit_signal(&"property_list_changed")




#region Values


## Returns whether [param name] is valid [code]field[/code] name.
static func is_valid_field_name(name: StringName) -> bool:
	if name.is_empty():
		return false
	if name == &"field_name":
		return false
	if name.unicode_at(0) in range("0".unicode_at(0), "9".unicode_at(0) + 1) \
		or name.begins_with("_"):
			return false
	for i in name.length():
		if name.unicode_at(i) not in (
			range("A".unicode_at(0), "Z".unicode_at(0) + 1) + \
			range("a".unicode_at(0), "z".unicode_at(0) + 1) + \
			[ "_".unicode_at(0) ]):
				return false
	return true




## @experimental
## Returns type-derived default value. Used internally.[br]
## At this moment, [Object] classes aren't supported by the method, so if [param type] equals [member TYPE_OBJECT] this method will return [code]null[/code]
static func type_default_value(type: Variant.Type):
	var value
	match type:
		TYPE_NIL: value = null
		TYPE_BOOL: value = false
		TYPE_INT: value = 0
		TYPE_FLOAT: value = 0.0
		TYPE_STRING: value = ""
		TYPE_VECTOR2: value = Vector2()
		TYPE_VECTOR2I: value = Vector2i()
		TYPE_RECT2: value = Rect2()
		TYPE_RECT2I: value = Rect2i()
		TYPE_VECTOR3: value = Vector3()
		TYPE_VECTOR3I: value = Vector3i()
		TYPE_TRANSFORM2D: value = Transform2D()
		TYPE_VECTOR4: value = Vector4()
		TYPE_VECTOR4I: value = Vector4i()
		TYPE_PLANE: value = Plane()
		TYPE_QUATERNION: value = Quaternion()
		TYPE_AABB: value = AABB()
		TYPE_BASIS: value = Basis()
		TYPE_TRANSFORM3D: value = Transform3D()
		TYPE_PROJECTION: value = Projection()
		TYPE_COLOR: value = Color.WHITE
		TYPE_STRING_NAME: value = &""
		TYPE_NODE_PATH: value = ^""
		TYPE_OBJECT: value = null
		TYPE_DICTIONARY: value = {}
		_:
			if type in range(TYPE_ARRAY, TYPE_PACKED_COLOR_ARRAY):
				value = []
			else:
				value = null
	return value




## Returns whether [param value] is suit to be used as [param field] value.
func is_value_compatible(field: StringName, value):
	var type = signature[field].type
	var hint = signature[field].hint
	var hint_string = signature[field].hint_string
	
	if type == typeof(value):
	
		if type == TYPE_OBJECT:
			if hint == PROPERTY_HINT_RESOURCE_TYPE:
				return value.is_class(hint_string)
			return true
		
		return true
	
	if type in [ TYPE_BOOL, TYPE_INT, TYPE_FLOAT ]:
		if typeof(value) in [ TYPE_BOOL, TYPE_INT, TYPE_FLOAT ]:
			return true
	
	if type in [ TYPE_VECTOR2, TYPE_VECTOR2I ]:
		if typeof(value) in [ TYPE_VECTOR2, TYPE_VECTOR2I ]:
			return true
	
	if type in [ TYPE_RECT2, TYPE_RECT2I ]:
		if typeof(value) in [ TYPE_VECTOR2, TYPE_VECTOR2I ]:
			return true
	
	if type in [ TYPE_VECTOR3, TYPE_VECTOR3I ]:
		if typeof(value) in [ TYPE_VECTOR2, TYPE_VECTOR2I ]:
			return true
	
	if type in [ TYPE_VECTOR4, TYPE_VECTOR4I ]:
		if typeof(value) in [ TYPE_VECTOR2, TYPE_VECTOR2I ]:
			return true
	
	if type in [ TYPE_VECTOR2, TYPE_VECTOR2I ]:
		if typeof(value) in [ TYPE_VECTOR2, TYPE_VECTOR2I ]:
			return true
	
	
	if type in [ TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH ]:
		if typeof(value) in [ TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH ]:
			return true
	
	return false




## Returns name that can be used as [code]field[/code] name. Parameter [param name] is the name that will be modified and returned.
func unique_name(name: StringName) -> StringName:
	if name in signature:
		var num = [] as PackedStringArray
		name = name.reverse()
		for i in name.length():
			if name.unicode_at(i) in range("0".unicode_at(0), "9".unicode_at(0)):
				num.push_back(name.substr(i, 1))
		num = "".join(num).reverse()
		name = name.reverse()
		if num.is_valid_int():
			name = name.left(-num.length()) + String.num_int64(int(num) + 1)
		else:
			name = unique_name(name.trim_suffix("_") + "_2")
	return name


#endregion



## @deprecated
## Returns StructServer singleton.
static func get_server():
	return Engine.get_singleton(&"StructServer")




## Helper for rearrange fields in signature (or [i]any other[/i] dictionary, so it may be more useful).[br]
## [br]
## Parameters: [param dict] is target [Dictionary], [param from] is original element index, [param to] is element target position.[br]
## Returns [i]copy[/i] of modified dictionary.
static func dict_move_to(dict: Dictionary, from: int, to: int) -> Dictionary:
	var temp = dict.duplicate(1)
	
	if temp.is_empty(): return temp
	to = clampi(to, 0, temp.size())
	if from == to: return temp
	if from < 0 or from > temp.size(): return temp
	
	var keys = temp.keys().duplicate(1)
	var key = keys[from]
	keys.remove_at(from)
	keys.insert(to, key)
	
	var values = temp.values().duplicate(1)
	var value = values[from]
	values.remove_at(from)
	values.insert(to, value)
	
	temp.clear()
	for i in keys.size():
		temp[keys[i]] = values[i]
	return temp




## Returns [Struct] instance based on [code]self[/code]. If [StructureBase] haven't been saved to file, returns [code]null[/code] structure.
func make(init_values: Dictionary) -> Struct:
	if FileAccess.file_exists(resource_path):
		var r_value = Struct.new(resource_path)
		r_value.modify(init_values)
		return r_value
	return null




## Returns whether structure is empty, i.e. its signature doesn't contain any field.
func is_empty():
	return signature.is_empty()




## @experimental
## Returns name of structure
func get_struct_id():
	if resource_path.is_empty():
		return "<unsaved>"
	return resource_path.get_file().get_basename().split(".", 0)[-1]
