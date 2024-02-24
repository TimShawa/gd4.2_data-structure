@tool
@icon("res://addons/structure_resource/icon_structure.svg")
extends Resource
class_name Struct


## @experimental
## Class for contain data in fixed amount of members based on its base.
##
## [Struct] can be created with [method Object.new] with path to [StructureBase] file:
## [codeblock]
## var struct = Struct.new(PATH_TO_BASE)
## [/codeblock]
## Access members:
## [codeblock]
## # field_a = 17, field_b = "structures are useful!"
## 
## print( struct.field_a )      # output: "17"
## print( struct.field_b )      # output: "structures are useful!"
## [/codeblock]
## Modify members ([method modify]):
## [codeblock]
## struct.modify({
##     field_a = 8,
##     field_c = 0.12    # will be rejected: struct doesn't have "field_c" member.
## })
## 
## print( struct.field_a )      # output: "8"
## print( struct.field_b )      # output: "structures are useful!"
## [/codeblock]
## Reset to defaults ([method revert]:
## [codeblock]
## # "field_a" did set to 8 in prev. example; default is 17
## 
## struct.revert("field_a")     # revert to default value
## print( struct.field_a )      # output: 17
## [/codeblock]
## To check if structure is an instance of certain [StructureBase], use [method StructureBase.is_instance] method.[br]




#region Variables

#region private

## [i]DO NOT SET IT MANUALLY, create NEW structure with needed base instead![br]
## [br]
## Path to base ([StructureBase]) in filesystem.
var __base_path__: String = ""

## [i]DO NOT SET IT MANUALLY, create NEW structure with needed base instead![br]
## [br]
## Structure base defining its fields and defaults.
var __base__: StructureBase

## Actual data stored in [Struct]. Can be used for access its members or set them without instance updating, but [i]it is NOT recommended[/i].
## Use [method modify] instead to change and [code]struct.field[/code] to access structure data.
var __data__: Dictionary = {}

#endregion

#endregion




#region Built-in Functions


## [Struct] contructor. Parameter [param on_base] is the path to valid [StructureBase] resource saved as [i][b]file[/b][/i].
## After creating, [method modify] will called, setting memders to their [param init_values].[br]
## If [param on_base] is empty, [Struct] keeps to be unconfigured and wait to first [member __base_path__] setting (in this case use [method _set_base_path]).
func _init(on_base: String = "", init_values := {}):
	if on_base:
		__base_path__ = on_base
		__base__ = load(__base_path__)
		__data__ = __base__.default_values.duplicate(1)
		modify(init_values)
	else:
		if __base_path__:
			__base__ = load(__base_path__)
			__data__ = __base__.default_values.duplicate(1)
	
	#region Connect Signals
	connect(&"changed", notify_property_list_changed)
	#endregion
	
	notify_property_list_changed()


#region properties

func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = [
		{
			name = &"path to base",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT,
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
	if property in __data__:
		return __data__[property]


func _set(property: StringName, value: Variant) -> bool:
	if property == &"path to base":
		var base = load(value)
		if is_instance_valid(base):
			__base_path__ = value
			__base__ = base
			__data__ = __base__.default_values.duplicate(1)
			emit_changed()
			return true
		push_error("Invalid base!")
	if property in __data__:
		if __base__.is_value_compatible(property, value):
			__data__[property] = value
			emit_changed()
			return true
	return false


func _property_can_revert(property: StringName) -> bool:
	if property == &"path to base":
		return false
	if property in __data__:
		return __data__[property] != __base__.default_values[property]
	return false


func _property_get_revert(property: StringName):
	if property in __base__.default_values:
		return __base__.default_values[property]

#endregion


#endregion


#region Private Functions


func _set_base_path(new_path: String):
	set(&"path to base", new_path)


#endregion


#region Public Functions


## Returns an array of structure field names ([i]read-only[/i]). If [member __base__] haven't been loaded, returns empty [Array].[br]
## See also [method values].
func fields() -> Array[StringName]:
	var r_value: Array[StringName] = []
	for field: StringName in __data__.keys():
		r_value.push_back(field)
	r_value.make_read_only()
	return r_value


## Returns an array of structure values ([i]read-only[/i]). If [member __base__] haven't been loaded, returns empty [Array].[br]
## See also [method fields].
func values() -> Array:
	if __data__:
		var r_value = __data__.values().duplicate()
		r_value.make_read_only()
		return r_value
	return []


## Remaps elements of stucture depending on [code]field:value[/code] pairs in [param map].[br]
## If [Struct] doesn't contain certain element, it will be skipped. This rule also applies to incompatible values.
func modify(map: Dictionary):
	if __data__:
		for field in map:
			if field in __data__:
				if field in __base__.signature:
					if __base__.is_value_compatible(field, map[field]):
						__data__[field] = map[field]
		emit_changed()


## Reverts specified [param field] value to its default.
func revert(field: StringName):
	if __base__:
		if field in __data__:
			set(field, __base__.default_values[field])


## Returns copy of srructure's [code]__data__[/code].
func extract():
	return __data__.duplicate(1)

#endregion
