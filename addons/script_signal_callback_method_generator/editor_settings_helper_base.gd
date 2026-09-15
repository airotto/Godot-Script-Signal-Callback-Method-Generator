@abstract
extends RefCounted

var _plugin_name:String
var _setting_property_list:Array[String]

#{
	#"plugin/setting_path":{
		#"ja":"説明",
		#"en":"description"
	#}
#}
var _setting_description_list:Dictionary[String, Dictionary]

##これを継承先で使用してadd_settingをしてください。
@abstract func _add_settings_initialized() -> void


func _init(p_plugin_name:String, plugin_node:EditorPlugin) -> void:
	_plugin_name = p_plugin_name
	
	_description_system_initialized()
	
	_add_settings_initialized()
	
	add_setting("other/clean_up_editor_settings_when_disabling_the_plugin", false, TYPE_BOOL)
	set_description("other/clean_up_editor_settings_when_disabling_the_plugin", "en",
"Cleans up editor settings when the plugin is deactivated
(Use this to prevent settings from remaining even after you stop using the plugin.)")
	set_description("other/clean_up_editor_settings_when_disabling_the_plugin", "ja",
"プラグイン無効化時にエディター設定をクリーンアップします。
(プラグインをもう使わない場合に設定が残り続けるのを防ぐためにこれを使用してください。)")
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
	if get_setting("other/clean_up_editor_settings_when_disabling_the_plugin"):
		_remove_setting_all()


func _remove_setting_all() -> void:
	var settings := EditorInterface.get_editor_settings()
	
	for property:String in _setting_property_list:
		settings.erase(property)


func _get_plugin_settigns_dir() -> String:
	return "plugins/" + _plugin_name + "/"


func set_description(property_name:String, locale:String, description:String) -> void:
	var property:String = _get_plugin_settigns_dir() + property_name
	
	if not _setting_description_list.has(property):
		_setting_description_list[property] = {}# as Dictionary[String, Dictionary]
	
	if not _setting_description_list[property].has(locale):
		_setting_description_list[property][locale] = {}# as Dictionary[String, String]
	
	_setting_description_list[property][locale] = description




func _description_system_initialized() -> void:
	var editor_settings_dialog:Node = EditorInterface.get_base_control().find_child("*EditorSettingsDialog*", false, false)
	
	EditorInterface.get_base_control().get_tree().node_added.connect(_on_node_added.bind(editor_settings_dialog))

const EditorHelpBitToolTipHelper = preload("editor_help_bit_tool_tip_helper.gd")
func _on_node_added(node: Node, editor_settings_dialog:Node) -> void:
	if node is PopupPanel:
		if node.get_class() == "EditorHelpBitTooltip":
			if editor_settings_dialog.is_ancestor_of(node):
				
				if not node.is_node_ready():
					await node.ready
				
				var tooltip_helper := EditorHelpBitToolTipHelper.new(node)
				_on_tooltip_entered(tooltip_helper)

func _on_tooltip_entered(tooltip_helper:EditorHelpBitToolTipHelper) -> void:
	for property:String in _setting_description_list.keys():
		if tooltip_helper.title_label.get_parsed_text().ends_with(property):
			tooltip_helper.text_label.bbcode_enabled = true
			
			#var locale_description_list:Dictionary[String, String] = _setting_description_list[property]
			var locale_description_list:Dictionary = _setting_description_list[property]
			var description:String = locale_description_list["en"]
			var locale:String = TranslationServer.get_locale()
			if locale_description_list.has(locale):
				description = locale_description_list[locale]
			tooltip_helper.text_label.text = _convert_custom_bbcode(description)

func _convert_custom_bbcode(text:String) -> String:
	const CODE_FONT_PATH:String = "res://addons/script_signal_callback_method_generator/cache/code_font.res"
	if not ResourceLoader.exists(CODE_FONT_PATH):
		var code_font := EditorInterface.get_editor_theme().get_font(&"font", &"CodeEdit")
		ResourceSaver.save(code_font, CODE_FONT_PATH)
	
	const NOTE_ICON_PATH:String = "res://addons/script_signal_callback_method_generator/cache/note_icon.res"
	if not ResourceLoader.exists(NOTE_ICON_PATH):
		var note_icon := EditorInterface.get_editor_theme().get_icon(&"NodeInfo", &"EditorIcons")
		ResourceSaver.save(note_icon, NOTE_ICON_PATH)
	const WARNING_ICON_PATH:String = "res://addons/script_signal_callback_method_generator/cache/warning_icon.res"
	if not ResourceLoader.exists(WARNING_ICON_PATH):
		var note_icon := EditorInterface.get_editor_theme().get_icon(&"NodeWarning", &"EditorIcons")
		ResourceSaver.save(note_icon, WARNING_ICON_PATH)
	const TIP_ICON_PATH:String = "res://addons/script_signal_callback_method_generator/cache/tip_icon.res"
	if not ResourceLoader.exists(TIP_ICON_PATH):
		var note_icon := EditorInterface.get_editor_theme().get_icon(&"StatusSuccess", &"EditorIcons")
		ResourceSaver.save(note_icon, TIP_ICON_PATH)
	const IMPORTANT_ICON_PATH:String = "res://addons/script_signal_callback_method_generator/cache/important_icon.res"
	if not ResourceLoader.exists(IMPORTANT_ICON_PATH):
		var note_icon := EditorInterface.get_editor_theme().get_icon(&"StatusWarning", &"EditorIcons")
		ResourceSaver.save(note_icon, IMPORTANT_ICON_PATH)
	
	
	
	## editor/doc/editor_help.cpp 2740
	var code_color:String = _get_editor_color(&"code_color", &"EditorHelp").lerp(_get_editor_color(&"error_color", &"Editor"), 0.6).to_html()
	var code_bg_color:String = _get_editor_color(&"code_bg_color", &"EditorHelp").to_html()
	text = text.replace("[code]", "[color=" + code_color + "][bgcolor=" + code_bg_color + "][font=" + CODE_FONT_PATH + "]")
	text = text.replace("[/code]", "[/font][/bgcolor][/color]")
	
	var note_color:String = _get_editor_color(&"note_color", &"EditorHelp").to_html()
	text = text.replace("[note]", "[color=" + note_color +"][img color=" + note_color + "]" + NOTE_ICON_PATH +  "[/img]" + "[b]Note[/b]: ")
	text = text.replace("[/note]", "[/color]")
	
	var warning_color:String = _get_editor_color(&"warning_color", &"EditorHelp").to_html()
	text = text.replace("[warning]", "[color=" + warning_color +"][img color=" + warning_color + "]" + WARNING_ICON_PATH +  "[/img]" + "[b]Warnig[/b]: ")
	text = text.replace("[/warning]", "[/color]")
	
	var tip_color:String = _get_editor_color(&"tip_color", &"EditorHelp").to_html()
	text = text.replace("[tip]", "[color=" + tip_color +"][img color=" + tip_color + "]" + TIP_ICON_PATH +  "[/img]" + "[b]Tip[/b]: ")
	text = text.replace("[/tip]", "[/color]")
	
	var important_color:String = _get_editor_color(&"important_color", &"EditorHelp").to_html()
	text = text.replace("[important]", "[color=" + important_color +"][img color=" + important_color + "]" + IMPORTANT_ICON_PATH +  "[/img]" + "[b]Important[/b]: ")
	text = text.replace("[/important]", "[/color]")
	
	
	return text


func _get_editor_color(name:StringName, theme_type:StringName) -> Color:
	return EditorInterface.get_editor_theme().get_color(name, theme_type)
