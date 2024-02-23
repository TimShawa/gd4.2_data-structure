@tool
extends EditorPlugin


const SERVER_ENABLED = false
var insp_plugin_struct_config: EditorInspectorPlugin = preload('res://addons/structure_resource/insp_editor_structure/insp_plugin.gd').new()

func _enter_tree() -> void:
	if SERVER_ENABLED: Engine.register_singleton(&"StructServer", load("res://addons/structure_resource/struct_server.gd").new())
	add_inspector_plugin(insp_plugin_struct_config)


func _exit_tree() -> void:
	remove_inspector_plugin(insp_plugin_struct_config)
	if SERVER_ENABLED: Engine.unregister_singleton(&"StructServer")
