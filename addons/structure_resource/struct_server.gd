@tool
extends Object
class_name StructServer

signal signature_changed(structure: StringName, signature: Dictionary)


var identifiers: Array[StringName] = []
var paths: PackedStringArray = []
const STRUCTURE = preload("res://addons/structure_resource/structure_base.gd")



func _init():
	fill_ids()


func fill_ids(edfs: EditorFileSystemDirectory = EditorInterface.get_resource_filesystem().get_filesystem()):
	for i in edfs.get_subdir_count():
		fill_ids(edfs.get_subdir(i))
	for i in edfs.get_file_count():
		if EditorInterface.get_resource_filesystem().get_file_type( edfs.get_file_path(i) ) == &"Resource":
			var strc = load(edfs.get_file_path(i))
			if strc is STRUCTURE:
				identifiers.push_back(strc.get_struct_id())


func update_signature(structure: StringName, signature: Dictionary):
	emit_signal(&"signature_changed", structure, signature)




func test_functionality():
	print("StructServer: functional")
