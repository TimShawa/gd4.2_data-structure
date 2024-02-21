@tool
extends Node



@export var structure: struct


func _enter_tree() -> void:
	var base = StructureBase.new({ &"field": { type = TYPE_INT } })
	structure = struct.new(base)
	print(structure.__data__)
