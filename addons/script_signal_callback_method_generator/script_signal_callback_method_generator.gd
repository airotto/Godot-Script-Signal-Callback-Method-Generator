@tool
extends EditorPlugin

const Setting = preload("uid://cx3mwmieov2vg")
var setting:Setting

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass
	setting = Setting.new("script_signal_callback_method_generator", self)
	
	initialized()



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


#####################################
#####################################



#####################################
#####################################


#signal  test_test_test
func _is_signal(text:String) -> bool:
	var editor_domain := TranslationServer.get_or_add_domain(&"godot.editor")
	
	var signal_string:String = editor_domain.translate(&"Signal")
	
	return text.begins_with(signal_string)

func _get_action_text_for_create_signal_callback_method() -> String:
	match TranslationServer.get_tool_locale():
		"ja":
			match setting.get_setting_action_mode():
				Setting.ActionMode.COPY:
					return "シグナルのコールバックメソッドをクリップボードにコピー"
				Setting.ActionMode.GENERATE:
					return "シグナルのコールバックメソッドを作成"
		_:
			match setting.get_setting_action_mode():
				Setting.ActionMode.COPY:
					return "Copy the Signal callback method to the clipboard"
				Setting.ActionMode.GENERATE:
					return "Create the Signal callback method"
	return "Error text"

func _get_action_text_for_create_connect_only() -> String:
	match TranslationServer.get_tool_locale():
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
	
	if tooltip_helper.tooltip.has_meta(&"_triggered___plugin_script_signal_callback_method_generator"):return
	tooltip_helper.tooltip.set_meta(&"_triggered___plugin_script_signal_callback_method_generator", true)
	
	
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
	
	if setting.get_setting_enable_connect_only_action():
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
	
	if setting.get_setting_create_connect():
		code_edit.begin_complex_operation()
		already_begin_complex_operation = true
		
		_create_connect(symbol, line, column, code_edit)
	
	
	match setting.get_setting_action_mode():
		Setting.ActionMode.COPY:
			DisplayServer.clipboard_set(function_text)
			if already_begin_complex_operation:
				code_edit.end_complex_operation()
		Setting.ActionMode.GENERATE:
			
			
			if not setting.get_setting_force_generate():
				var serch_text:String = "func " + _get_function_name(symbol, line, column, code_edit)
				for i in code_edit.get_line_count():
					if code_edit.get_line(i).begins_with(serch_text):
						#code_edit.select(i, 0, i, code_edit.get_line(i).length())
						if already_begin_complex_operation:
							code_edit.end_complex_operation()
						
						match TranslationServer.get_tool_locale():
							"ja":
								print("すでにその名前の関数が存在するため作成されませんでした。(この動作は 'force_generate' で変更できます)")
							_:
								print("The function was not created because a function with that name already exists. (This behavior can be changed in 'force_generate'.)")
						return
			
			
			if not already_begin_complex_operation:
				code_edit.begin_complex_operation()
			_force_final_new_line(code_edit)
			
			
			
			
			
			
			
			
			var callback_create_line:int
			
			match setting.get_setting_action_generate_mode():
				Setting.ActionGenerateMode.BOTTOM:
					callback_create_line = code_edit.get_line_count() - 1
				Setting.ActionGenerateMode.NEXT:
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
			if setting.get_setting_select_initial_text():
				
				code_edit.select(
					callback_create_line + setting.get_setting_line_space() + 1,
					_get_indent().length(),
					callback_create_line + setting.get_setting_line_space() + 1,
					_get_indent().length() + setting.get_setting_initial_text().length()
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
		match TranslationServer.get_tool_locale():
			"ja":
				print("すでに続きが記述されているため接続が作成されませんでした。")
			_:
				print("Since the rest has already been entered, connect was not created.")
	else:
		match TranslationServer.get_tool_locale():
			"ja":
				print("宣言位置なため接続が作成されませんでした。")
			_:
				print("A connection was not created because it was a declaration.")
	return false



func _get_function_text(symbol: String, line: int, column: int, code_edit:CodeEdit, tooltip_helper:EditorHelpBitToolTipHelper) -> String:
	
	var title_text:String = tooltip_helper.title_label.get_parsed_text()
	var arg:String = "(" + title_text.get_slice("(", 1)
	arg = arg.replace(" ", " ")##正しいスペースに直す。元はU+00A0でエラーが出る
	
	var function_text:String = "\n".repeat(0 if setting.get_setting_action_mode() == Setting.ActionMode.COPY else setting.get_setting_line_space()) + "func " + _get_function_name(symbol, line, column, code_edit) + arg + (" -> " + setting.get_setting_type() if setting.get_setting_type() else "") + ":" + "\n" + _get_indent() + setting.get_setting_initial_text()
	
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
