@tool
extends EditorPlugin

var insp_plugin_enum_config: EditorInspectorPlugin = preload("res://addons/enum_resource/insp_editor_enum/insp_plugin.gd").new()
func _enter_tree() -> void:
	add_inspector_plugin(insp_plugin_enum_config)
	pass


func _exit_tree() -> void:
	remove_inspector_plugin(insp_plugin_enum_config)
	pass
