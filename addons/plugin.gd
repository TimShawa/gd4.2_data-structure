@tool
extends EditorPlugin


var insp_plugin_struct_config: EditorInspectorPlugin = preload('res://addons/structure_resource/insp_editor_structure/insp_plugin.gd').new()


func _enter_tree() -> void:
	add_inspector_plugin(insp_plugin_struct_config)


func _exit_tree() -> void:
	remove_inspector_plugin(insp_plugin_struct_config)
