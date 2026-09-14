@abstract
extends RefCounted

var _plugin_name:String
var _setting_property_list:Array[String]


@abstract func _add_settings_initialized() -> void


func _init(p_plugin_name:String, plugin_node:EditorPlugin) -> void:
	_plugin_name = p_plugin_name
	
	_add_settings_initialized()
	
	add_setting("other/clear_editor_settings_when_disabling_the_plugin", false, TYPE_BOOL)
	plugin_node.tree_exiting.connect(_on_plugin_tree_exiting)


func add_setting(property_name:String, default_value:Variant, type:Variant.Type, hint:PropertyHint = PROPERTY_HINT_NONE, hint_string:String = "") -> void:
	var settings := EditorInterface.get_editor_settings()
	
	var property:String = _get_plugin_settigns_dir() + property_name
	
	if not settings.has_setting(property):
		settings.set(property, default_value)
	
	
	var property_info = {
		"name": property,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
	}
	
	settings.add_property_info(property_info)
	settings.set_initial_value(property, default_value, false)
	
	if not _setting_property_list.has(property):
		_setting_property_list.append(property)


func remove_setting(property_name:String) -> void:
	var settings := EditorInterface.get_editor_settings()
	
	var property:String = _get_plugin_settigns_dir() + property_name
	
	settings.erase(property)
	
	if _setting_property_list.has(property):
		_setting_property_list.erase(property)


func get_setting(property_name:String) -> Variant:
	var settings := EditorInterface.get_editor_settings()
	return settings.get_setting(_get_plugin_settigns_dir() + property_name)


func _on_plugin_tree_exiting() -> void:
	if get_setting("other/clear_editor_settings_when_disabling_the_plugin"):
		_remove_setting_all()


func _remove_setting_all() -> void:
	var settings := EditorInterface.get_editor_settings()
	
	for property:String in _setting_property_list:
		settings.erase(property)


func _get_plugin_settigns_dir() -> String:
	return "plugins/" + _plugin_name + "/"
