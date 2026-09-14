@tool
extends EditorPlugin

const _PLUGIN_SETTIGNS_DIR:String = "plugins/script_signal_callback_method_generator/"
enum _ActionMode{
	COPY, ##クリップボードにコピー
	GENERATE, ##生成されます。位置については[code]_ActionGenerateMode[/code]
}
enum _ActionGenerateMode{
	BOTTOM, ##最下部
	NEXT, ##次にインデントが無い行
}

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass
	initialized_settings()
	initialized()



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
	if get_setting_clear_editor_settings_when_disabling_the_plugin():
		remove_setting_all()


#####################################
#####################################
func initialized_settings() -> void:
	##[code]F_ACTION_MODE[/code]が[code]_ActionMode.GENERATE[/code]の時、生成時の上の関数との行間隔
	add_setting("line_space", 2, TYPE_INT, PROPERTY_HINT_RANGE, "0, 1, 1, or_greater")
	##戻り型。空でも可
	add_setting("type", "void", TYPE_STRING)
	
	add_setting("initial_text", "pass", TYPE_STRING)
	##[code]F_ACTION_MODE[/code]が[code]_ActionMode.GENERATE[/code]の時、生成時に自動で[code]F_INITIAL_TEXT[/code]を選択する
	add_setting("select_initial_text", true, TYPE_BOOL)
	##connect()を作成する。[br][note][code]F_ACTION_MODE[/code]が何の場合でもこの設定は機能します。[/note]
	add_setting("create_connect", true, TYPE_BOOL)
	
	add_setting("action_mode", _ActionMode.find_key(_ActionMode.GENERATE), TYPE_STRING, PROPERTY_HINT_ENUM, ",".join(_ActionMode.keys()) )
	
	add_setting("action_generate_mode", _ActionGenerateMode.find_key(_ActionGenerateMode.NEXT), TYPE_STRING, PROPERTY_HINT_ENUM, ",".join(_ActionGenerateMode.keys()) )
	##connect()作成のみのアクションを新たに追加する
	add_setting("enable_connect_only_action", true, TYPE_BOOL)
	##[code]F_ACTION_MODE[/code]が[code]_ActionMode.GENERATE[/code]の時、すでにその名前の関数がある場合でも作成する
	add_setting("force_generate", false, TYPE_BOOL)
	
	# Clear Editor Settings When Disabling the Plugin
	add_setting("other/clear_editor_settings_when_disabling_the_plugin", false, TYPE_BOOL)
	


func add_setting(property:String, default_value:Variant, type:Variant.Type, hint:PropertyHint = PROPERTY_HINT_NONE, hint_string:String = "") -> void:
	var settings := EditorInterface.get_editor_settings()
	
	var final_property:String = _PLUGIN_SETTIGNS_DIR + property
	
	if not settings.has_setting(final_property):
		settings.set(final_property, default_value)
	
	
	var property_info = {
		"name": final_property,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
	}
	
	settings.add_property_info(property_info)
	settings.set_initial_value(final_property, default_value, false)
	
	
	
	

func remove_setting_all() -> void:
	remove_setting("line_space")
	remove_setting("type")
	remove_setting("initial_text")
	remove_setting("select_initial_text")
	remove_setting("create_connect")
	remove_setting("action_mode")
	remove_setting("action_generate_mode")
	remove_setting("enable_connect_only_action")
	remove_setting("force_generate")
	remove_setting("other/clear_editor_settings_when_disabling_the_plugin")
	

func remove_setting(property:String) -> void:
	var settings := EditorInterface.get_editor_settings()
	settings.erase(_PLUGIN_SETTIGNS_DIR + property)
	


func get_setting(property:String) -> Variant:
	var settings := EditorInterface.get_editor_settings()
	return settings.get_setting(_PLUGIN_SETTIGNS_DIR + property)

func get_setting_line_space() -> int: return get_setting("line_space")
func get_setting_type() -> String: return get_setting("type")
func get_setting_initial_text() -> String: return get_setting("initial_text")
func get_setting_select_initial_text() -> bool: return get_setting("select_initial_text")
func get_setting_create_connect() -> bool: return get_setting("create_connect")
func get_setting_action_mode() -> _ActionMode: return _ActionMode[get_setting("action_mode")]
func get_setting_action_generate_mode() -> _ActionGenerateMode: return _ActionGenerateMode[get_setting("action_generate_mode")]
func get_setting_enable_connect_only_action() -> bool: return get_setting("enable_connect_only_action")
func get_setting_force_generate() -> bool: return get_setting("force_generate")
func get_setting_clear_editor_settings_when_disabling_the_plugin() -> bool: return get_setting("clear_editor_settings_when_disabling_the_plugin")


#####################################
#####################################


#signal  test_test_test
func _is_signal(text:String) -> bool:
	var locale:String = TranslationServer.get_locale()
	#print()
	#print(locale)
	#print(text)
	
	
	const LOCALE_SIGNAL_NAME_HASHMAP:Dictionary[String, String] = {
		"en":"Signal",
		"ar":"الإشارة",
		"bg":"Сигнал",
		"bn":"Signal",
		"ca":"Senyal",
		"cs":"Signál",
		"de":"Ereignis",
		"el":"Σήμα",
		"eo":"Signalo",
		"es":"Señal",
		"es_AR":"Señal",
		"et":"Signaal",
		"fa":"نشانه",
		"fi":"Signaali",
		"fr":"Signaux",
		"ga":"Comhartha",
		"gl":"Sinal",
		"he":"אות",
		"hu":"Jelzés",
		"id":"Sinyal",
		"it":"Segnale",
		"ja":"シグナル",
		"ka":"სიგნალი",
		"ko":"시그널",
		"lo":"ສັນຍານ",
		"nl":"Signaal",
		"pl":"Sygnał",
		"pt":"Sinal",
		"pt_BR":"Sinal",
		"ro":"Semnal",
		"ru":"Сигнал",
		"sk":"Signál",
		"sv":"Signal",
		"ta":"குறிகை",
		"th":"สัญญาณ",
		"tok":"Signal",
		"tr":"Sinyal",
		"uk":"Сигнал",
		"vi":"Tín hiệu",
		"zh_Hans":"信号",
		"zh_Hant":"訊號",
		
	}
	
	return text.begins_with(LOCALE_SIGNAL_NAME_HASHMAP.get(locale, "Signal") )

func _get_action_text_for_create_signal_callback_method() -> String:
	match TranslationServer.get_locale():
		"ja":
			match get_setting_action_mode():
				_ActionMode.COPY:
					return "シグナルのコールバックメソッドをクリップボードにコピー"
				_ActionMode.GENERATE:
					return "シグナルのコールバックメソッドを作成"
		_:
			match get_setting_action_mode():
				_ActionMode.COPY:
					return "Copy the Signal callback method to the clipboard"
				_ActionMode.GENERATE:
					return "Create the Signal callback method"
	return "Error text"

func _get_action_text_for_create_connect_only() -> String:
	match TranslationServer.get_locale():
		"ja":
			return "接続のみを作成"
		_:
			return "Create connect only"
	return "Error text"

#####################################
#####################################

func initialized() -> void:
	var script_editor:ScriptEditor = EditorInterface.get_script_editor()
	if not script_editor.is_node_ready():
		await script_editor.ready
	
	script_editor.editor_script_changed.connect(update_code_edits.bind(script_editor).unbind(1))
	update_code_edits(script_editor)

const EditorHelpBitToolTipHelper = preload("uid://cjxcsth0mfqhe")
const _ACTION_CREATE_SIGNAL_CALLBACK_METHOD_META:String = "create_signal_callback_method"
const _ACTION_CREATE_CONNECT_ONLY_META:String = "create_connect_only"


func _on_symbol_hovered(symbol: String, line: int, column: int, code_edit:CodeEdit) -> void:
	if code_edit == null:return
	
	##表示時のみノードが生成されるのでホバーごとにトリガー
	##ツールチップを取得
	var tooltip_node:PopupPanel = code_edit.find_child("*EditorHelpBitTooltip*", false, false)
	if tooltip_node == null:return
	
	
	var tooltip_helper:EditorHelpBitToolTipHelper = EditorHelpBitToolTipHelper.new(tooltip_node)
	
	if tooltip_helper.tooltip.has_meta(&"_triggered___plugin_script_signal_function_generator"):return
	tooltip_helper.tooltip.set_meta(&"_triggered___plugin_script_signal_function_generator", true)
	
	
	var title_text:String = tooltip_helper.title_label.get_parsed_text()
	if not _is_signal(title_text):return
	
	
	_trigger(symbol, line, column, code_edit, tooltip_helper)


func _trigger(symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> void:
	var action_quantity:int = 0
	
	_add_action(
		_ACTION_CREATE_SIGNAL_CALLBACK_METHOD_META,
		EditorInterface.get_base_control().get_theme_icon(&"Signal", &"EditorIcons"),
		_get_action_text_for_create_signal_callback_method(),
		tooltip_helper
	)
	action_quantity += 1
	
	if get_setting_enable_connect_only_action():
		_add_action(
		_ACTION_CREATE_CONNECT_ONLY_META,
		EditorInterface.get_base_control().get_theme_icon(&"Signals", &"EditorIcons"),
		_get_action_text_for_create_connect_only(),
		tooltip_helper
		)
		action_quantity += 1
	
	tooltip_helper.text_label.meta_clicked.connect(_on_meta_clicked.bind(symbol, line, column, code_edit, tooltip_helper))
	
	if not tooltip_helper.text_label.is_finished():
		await tooltip_helper.text_label.finished
	
	for i in range(action_quantity, 0, -1):
		tooltip_helper.tooltip.size.y += tooltip_helper.text_label.get_line_height(tooltip_helper.text_label.get_line_count() - i)
	
	tooltip_helper.tooltip.size.y += tooltip_helper.text_label.get_line_height(tooltip_helper.text_label.get_line_count() - 1)


func _on_meta_clicked(meta:Variant, symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> void:
	if meta == _ACTION_CREATE_SIGNAL_CALLBACK_METHOD_META:
		_create_signal_callback_method(symbol, line, column, code_edit, tooltip_helper)
	if meta == _ACTION_CREATE_CONNECT_ONLY_META:
		_create_connect(symbol, line, column, code_edit)


func _add_action(meta:Variant, icon:Texture2D, text:String, tooltip_helper:EditorHelpBitToolTipHelper) -> void:
	tooltip_helper.text_label.newline()
	tooltip_helper.text_label.push_meta(meta, RichTextLabel.META_UNDERLINE_ON_HOVER)
	
	tooltip_helper.text_label.add_image(icon)
	tooltip_helper.text_label.add_text("  ")
	
	tooltip_helper.text_label.add_text(text)
	
	
	tooltip_helper.text_label.pop()



func _create_signal_callback_method(symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> void:
	var function_text:String = _get_function_text(symbol, line, column, code_edit, tooltip_helper)
	
	var already_begin_complex_operation:bool = false
	
	if get_setting_create_connect():
		code_edit.begin_complex_operation()
		already_begin_complex_operation = true
		
		_create_connect(symbol, line, column, code_edit)
	
	
	match get_setting_action_mode():
		_ActionMode.COPY:
			DisplayServer.clipboard_set(function_text)
			if already_begin_complex_operation:
				code_edit.end_complex_operation()
		_ActionMode.GENERATE:
			
			
			if not get_setting_force_generate():
				var serch_text:String = "func " + _get_function_name(symbol, line, column, code_edit)
				for i in code_edit.get_line_count():
					if code_edit.get_line(i).begins_with(serch_text):
						#code_edit.select(i, 0, i, code_edit.get_line(i).length())
						if already_begin_complex_operation:
							code_edit.end_complex_operation()
						
						match TranslationServer.get_locale():
							"ja":
								print("すでにその名前の関数が存在するため作成されませんでした。(この動作は 'force_generate' で変更できます)")
							_:
								print("The function was not created because a function with that name already exists. (This behavior can be changed in 'force_generate'.)")
						return
			
			
			if not already_begin_complex_operation:
				code_edit.begin_complex_operation()
			_force_final_new_line(code_edit)
			
			
			
			
			
			
			
			
			var callback_create_line:int
			
			match get_setting_action_generate_mode():
				_ActionGenerateMode.BOTTOM:
					callback_create_line = code_edit.get_line_count() - 1
				_ActionGenerateMode.NEXT:
					_force_final_new_line(code_edit)
					
					##次にインデントが無い行を探す
					var next_no_indent_line:int
					for i in range(line + 1, code_edit.get_line_count()):
						next_no_indent_line = i
						
						if not code_edit.get_line(i).begins_with("	")\
						and not code_edit.get_line(i).begins_with(" ")\
						and not code_edit.get_line(i).begins_with(")")\
						and not code_edit.get_line(i).begins_with("]")\
						and not code_edit.get_line(i).begins_with("}"):
							break
					
					callback_create_line = next_no_indent_line
			
			
			##functionを作成
			
			code_edit.insert_line_at(callback_create_line, "")
			code_edit.insert_line_at(callback_create_line, function_text)
			
			code_edit.set_caret_line(callback_create_line + 1)
			if get_setting_select_initial_text():
				
				code_edit.select(
					callback_create_line + get_setting_line_space() + 1,
					_get_indent().length(),
					callback_create_line + get_setting_line_space() + 1,
					_get_indent().length() + get_setting_initial_text().length()
				)
			
			code_edit.end_complex_operation()


func _get_indent() -> String:
	var indent_size:int = EditorInterface.get_editor_settings().get_setting("text_editor/behavior/indent/size")
	var indent_type:int = EditorInterface.get_editor_settings().get_setting("text_editor/behavior/indent/type")
	const TAB:int = 0
	const SPACE:int = 1
	match indent_type:
		TAB:
			return "	"
		SPACE:
			return " ".repeat(indent_size)
	return ""

func _create_connect(symbol: String, line: int, column: int, code_edit:CodeEdit) -> bool:
	var is_property:bool = true
	##これがsignalが宣言されている場所ならconnectは作らない
	var left:String = code_edit.get_line(line).left(column)
	if left.get_slice_count(".") == 1:
		var splited := left.split(" ", false)
		if splited.size() >= 2:
			if splited[splited.size() - 2] == "signal":
				is_property = false
	
	
	if is_property:
		##connectを作成
		var right:String = code_edit.get_line(line).right(-column)
		if right.get_slice_count(".") == 1:
			var connect_text:String = ".connect(" + _get_function_name(symbol, line, column, code_edit) + ")"
			code_edit.insert_text(
				connect_text,
				line,
				 code_edit.get_line(line).length()
			)
			return true
	
	
	if is_property:
		match TranslationServer.get_locale():
			"ja":
				print("すでに続きが記述されているため接続が作成されませんでした。")
			_:
				print("Since the rest has already been entered, connect was not created.")
	else:
		match TranslationServer.get_locale():
			"ja":
				print("宣言位置なため接続が作成されませんでした。")
			_:
				print("A connection was not created because it was a declaration.")
	return false



func _get_function_text(symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> String:
	
	var title_text:String = tooltip_helper.title_label.get_parsed_text()
	var arg:String = "(" + title_text.get_slice("(", 1)
	arg = arg.replace(" ", " ")##正しいスペースに直す。元はU+00A0でエラーが出る
	
	var function_text:String = "\n".repeat(0 if get_setting_action_mode() == _ActionMode.COPY else get_setting_line_space()) + "func " + _get_function_name(symbol, line, column, code_edit) + arg + (" -> " + get_setting_type() if get_setting_type() else "") + ":" + "\n" + _get_indent() + get_setting_initial_text()
	
	return function_text


func _get_function_name(symbol: String, line: int, column: int, code_edit:CodeEdit) -> String:
	
	var left:String = code_edit.get_line(line).left(column)
	var sender_name:String = ""
	if left.get_slice_count(".") > 1:
		sender_name = left.get_slice(".", left.get_slice_count(".") - 2)
		sender_name = sender_name.get_slice("	", sender_name.get_slice_count("	") - 1)
		
		##"(*)"を削除。関数から直で接続するとき用 ( OptionButton.get_popup().id_pressed　とか )
		##TODO 2重以上の括弧だと機能しない
		if true:##() 用   (コピペできるようにスコープを分けてます)
			var regex := RegEx.create_from_string("\\([^\\)]+\\)")
			var regex_match := regex.search(sender_name)
			if regex_match:
				sender_name = sender_name.replace(regex_match.get_string(), "")
		if true:## [] 用   (コピペできるようにスコープを分けてます)
			var regex := RegEx.create_from_string("\\[[^\\]]+\\]")
			var regex_match := regex.search(sender_name)
			if regex_match:
				sender_name = sender_name.replace(regex_match.get_string(), "")
		
		
		##中身無しは別で(regexで処理されない)
		sender_name = sender_name.replace("()", "")
		
		
		
	if sender_name == "self":
		sender_name = ""
	
	var n:String = ProjectSettings.get_setting_with_override("editor/naming/default_signal_callback_name")
	var n_self:String = ProjectSettings.get_setting_with_override("editor/naming/default_signal_callback_to_self_name")
	
	return _get_callback_name(n if sender_name else n_self, sender_name, symbol)


func _get_callback_name(format:String, node_name:String, signal_name:String) -> String:
	format = format.replace("{NodeName}", node_name.to_pascal_case() )
	format = format.replace("{nodeName}",  node_name.to_camel_case() )
	format = format.replace("{node_name}",  node_name.to_snake_case() )
	
	format = format.replace("{SignalName}",  signal_name.to_pascal_case() )
	format = format.replace("{signalName}",  signal_name.to_camel_case() )
	format = format.replace("{signal_name}",  signal_name.to_snake_case() )
	
	return format


func _force_final_new_line(text_edit:TextEdit) -> void:
	##Ctrl+Sする前だと最後の行が空ではないので、無い場合に最後に空の行を作成
	if not text_edit.get_line(text_edit.get_line_count() - 1).is_empty():
		text_edit.insert_text("\n", text_edit.get_line_count() - 1, text_edit.get_line(text_edit.get_line_count() - 1).length())



func update_code_edits(script_editor:ScriptEditor) -> void:
	if script_editor.get_current_editor() == null:
		return
	var control:Control = script_editor.get_current_editor().get_base_editor()
	if control is not CodeEdit:return
	var code_edit:CodeEdit = control
	
	if not code_edit.symbol_hovered.is_connected(_on_symbol_hovered):
		code_edit.symbol_hovered.connect(_on_symbol_hovered.bind(code_edit))
