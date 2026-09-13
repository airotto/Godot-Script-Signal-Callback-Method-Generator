@tool
extends EditorPlugin

#region Settings
const F_LINE_SPACE:int = 2 ##[code]F_ACTION_MODE[/code]が[code]_ActionMode.GENERATE[/code]の時に生成時の上の関数との行間隔
const F_TYPE:String = "void" ##戻り値。空でも可
const F_INDENT:String = "	"
const F_INITIAL_TEXT:String = "pass"
const F_SELECT_INITIAL_TEXT:bool = true ##[code]F_ACTION_MODE[/code]が[code]_ActionMode.GENERATE[/code]の時に生成時に自動で[code]F_INITIAL_TEXT[/code]を選択する
const F_CREATE_CONNECT:bool = true ##connect()を作成する。[br][note][code]F_ACTION_MODE[/code]が何の場合でもこの設定は機能します。[/note]
const F_ACTION_MODE:_ActionMode = _ActionMode.GENERATE
const F_ACTION_GENERATE_MODE:_ActionGenerateMode = _ActionGenerateMode.NEXT
enum _ActionMode{
	COPY, ##クリップボードにコピー
	GENERATE, ##生成されます。位置については[code]_ActionGenerateMode[/code]
}
enum _ActionGenerateMode{
	BOTTOM, ##最下部
	NEXT, ##次にインデントが無い行
}
#endregion


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass
	initialized()



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


#####################################
#####################################

#signal  test_test_test
func _is_signal(text:String) -> bool:
	var locale:String = TranslationServer.get_locale()
	#print()
	#print(locale)
	#print(text)
	
	##自分用なので適当
	const LOCALE_SIGNAL_NAME_HASHMAP:Dictionary[String, String] = {
		"en":"Signal",
		"ar":"الإشارة",
		"de":"Ereignis",
		"es":"Señal",
		"fr":"Signaux",
		"it":"Segnale",
		"ja":"シグナル",
		"ko":"시그널",
		"pt":"Sinal",
		"uk":"Сигнал",
		"zh_Hans":"信号",
		"zh_Hant":"訊號",
		
	}
	
	return text.begins_with(LOCALE_SIGNAL_NAME_HASHMAP.get(locale, "Signal") )

#####################################
#####################################

func initialized() -> void:
	var script_editor:ScriptEditor = EditorInterface.get_script_editor()
	if not script_editor.is_node_ready():
		await script_editor.ready
	
	script_editor.editor_script_changed.connect(update_code_edits.bind(script_editor).unbind(1))
	update_code_edits(script_editor)

const EditorHelpBitToolTipHelper = preload("uid://cjxcsth0mfqhe")
const _CONVERT_TO_PATH_OR_UID_META_CLICK_TEXT:String = "convert_to_path_or_uid"


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
	
	tooltip_helper.text_label.newline()
	tooltip_helper.text_label.push_meta(_CONVERT_TO_PATH_OR_UID_META_CLICK_TEXT, RichTextLabel.META_UNDERLINE_ON_HOVER)
	
	
	var icon:Texture2D = EditorInterface.get_base_control().get_theme_icon(&"Signal", &"EditorIcons")
	tooltip_helper.text_label.add_image(icon)
	tooltip_helper.text_label.add_text("  ")
	
	var text:String = ""
	
	var locale:String = TranslationServer.get_locale()
	match locale:
		"ja":
			match F_ACTION_MODE:
				_ActionMode.COPY:
					text = "シグナルのコールバックメソッドをクリップボードにコピー"
				_ActionMode.GENERATE:
					text = "シグナルのコールバックメソッドを作成"
		_:
			match F_ACTION_MODE:
				_ActionMode.COPY:
					text = "Copy the Signal callback method to the clipboard"
				_ActionMode.GENERATE:
					text = "Create the Signal callback method"
	
	
	tooltip_helper.text_label.add_text(text)
	
	
	tooltip_helper.text_label.pop()
	tooltip_helper.text_label.meta_clicked.connect(_on_meta_clicked.bind(symbol, line, column, code_edit, tooltip_helper))
	
	if not tooltip_helper.text_label.is_finished():
		await tooltip_helper.text_label.finished
	
	tooltip_helper.tooltip.size.y += tooltip_helper.text_label.get_line_height(0)


func _on_meta_clicked(meta:Variant, symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> void:
	if meta == _CONVERT_TO_PATH_OR_UID_META_CLICK_TEXT:
		_create_signal_callback_method(symbol, line, column, code_edit, tooltip_helper)


func _create_signal_callback_method(symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> void:
	var function_text:String = _get_function_text(symbol, line, column, code_edit, tooltip_helper)
	
	var already_begin_complex_operation:bool = false
	
	if F_CREATE_CONNECT:
		code_edit.begin_complex_operation()
		already_begin_complex_operation = true
		_create_connect(symbol, line, column, code_edit)
	
	
	match F_ACTION_MODE:
		_ActionMode.COPY:
			DisplayServer.clipboard_set(function_text)
			if already_begin_complex_operation:
				code_edit.end_complex_operation()
		_ActionMode.GENERATE:
			if not already_begin_complex_operation:
				code_edit.begin_complex_operation()
			_force_final_new_line(code_edit)
			
			
			
			var callback_create_line:int
			
			match F_ACTION_GENERATE_MODE:
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
			if F_SELECT_INITIAL_TEXT:
				code_edit.select(
					callback_create_line + F_LINE_SPACE + 1,
					F_INDENT.length(),
					callback_create_line + F_LINE_SPACE + 1,
					F_INDENT.length() + F_INITIAL_TEXT.length()
				)
			
			code_edit.end_complex_operation()


func _create_connect(symbol: String, line: int, column: int, code_edit:CodeEdit) -> void:
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



func _get_function_text(symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> String:
	
	var title_text:String = tooltip_helper.title_label.get_parsed_text()
	var arg:String = "(" + title_text.get_slice("(", 1)
	arg = arg.replace(" ", " ")##正しいスペースに直す。元はU+00A0でエラーが出る
	
	var function_text:String = "\n".repeat(0 if F_ACTION_MODE == _ActionMode.COPY else F_LINE_SPACE) + "func " + _get_function_name(symbol, line, column, code_edit) + arg + (" -> " + F_TYPE if F_TYPE else "") + ":" + "\n" + F_INDENT + F_INITIAL_TEXT
	
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
