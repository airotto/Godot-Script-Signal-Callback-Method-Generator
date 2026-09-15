extends "editor_settings_helper_base.gd"

##[code]ActionGenerateMode[/code]ActionGenerateMode
enum ActionMode{
	COPY, ##クリップボードにコピー
	GENERATE, ##生成されます。位置については[code]ActionGenerateMode[/code]
}
enum ActionGenerateMode{
	BOTTOM, ##最下部
	NEXT, ##次にインデントが無い行
}


func _add_settings_initialized() -> void:
	
	add_setting("line_space", 2, TYPE_INT, PROPERTY_HINT_RANGE, "0, 1, 1, or_greater")
	set_description("line_space", "en", "The line spacing between this function and the one above it during generation when [code]action_mode[/code] is [code]ActionMode.GENERATE[/code].")
	set_description("line_space", "ja", "[code]action_mode[/code]が[code]ActionMode.GENERATE[/code]の時、生成時の上の関数との行間隔。")
	
	add_setting("type", "void", TYPE_STRING)
	set_description("type", "en", "Return type. May be left blank.")
	set_description("type", "ja", "戻り型。空でも可。")
	
	add_setting("initial_text", "pass", TYPE_STRING)
	set_description("initial_text", "en", "The initial text within the function at the time of creation.")
	set_description("initial_text", "ja", "生成時の関数内の初期テキスト。")
	
	add_setting("select_initial_text", true, TYPE_BOOL)
	set_description("select_initial_text", "en", "When [code]action_mode[/code] is [code]ActionMode.GENERATE[/code], [code]initial_text[/code] is automatically selected during generation.")
	set_description("select_initial_text", "ja", "[code]action_mode[/code]が[code]ActionMode.GENERATE[/code]の時、生成時に自動で[code]initial_text[/code]を選択する。")
	
	add_setting("create_connect", true, TYPE_BOOL)
	set_description("create_connect", "en", "Create a `connect()` function. [br][b]Note[/b]: This setting works regardless of the value of [code]action_mode.")
	set_description("create_connect", "ja", "connect()を作成する。[br][b]Note[/b]: [code]action_mode[/code]が何の場合でもこの設定は機能します。")
	
	add_setting("action_mode", ActionMode.find_key(ActionMode.GENERATE), TYPE_STRING, PROPERTY_HINT_ENUM, ",".join(ActionMode.keys()) )
	set_description("action_mode", "en",
"Types of Actions.

[b]Copy[/b]: Copy the syntax to Clipboard.

[b]Generate[/b]: Generate syntax.
For information on the generation position, see [code]action_generate_mode")
	set_description("action_mode", "ja",
"アクションの種類。

[b]Copy[/b]: クリッボードに構文をコピーします。

[b]Generate[/b]: 構文を生成します。
生成位置については[code]action_generate_mode[/code]を参照")
	
	add_setting("action_generate_mode", ActionGenerateMode.find_key(ActionGenerateMode.NEXT), TYPE_STRING, PROPERTY_HINT_ENUM, ",".join(ActionGenerateMode.keys()) )
	set_description("action_generate_mode", "en",
"When [code]action_mode[/code]is set to [code]ActionMode.GENERATE[/code], this determines where the syntax is generated.

[b]Bottom[/b]: Generates the syntax at the very bottom.

[b]Next[/b]: Generates the syntax at the next position where there is no indentation.")
	set_description("action_generate_mode", "ja",
"[code]action_mode[/code]が[code]ActionMode.GENERATE[/code]の時、どこに構文を生成するか。

[b]Bottom[/b]: 一番下に構文を生成します。

[b]Next[/b]: 次にインデントが無い位置に構文を生成します。")
	
	add_setting("enable_connect_only_action", true, TYPE_BOOL)
	set_description("enable_connect_only_action", "en", "Add a new action that simply creates connect().")
	set_description("enable_connect_only_action", "ja", "connect()作成のみのアクションを新たに追加する。")
	
	add_setting("force_generate", false, TYPE_BOOL)
	set_description("force_generate", "en", "When [code]action_mode[/code] is [code]ActionMode.GENERATE[/code], the function will be created even if one with that name already exists.")
	set_description("force_generate", "ja", "[code]action_mode[/code]が[code]ActionMode.GENERATE[/code]の時、すでにその名前の関数がある場合でも作成する。")
	
	Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL


func get_setting_line_space() -> int: return get_setting("line_space")
func get_setting_type() -> String: return get_setting("type")
func get_setting_initial_text() -> String: return get_setting("initial_text")
func get_setting_select_initial_text() -> bool: return get_setting("select_initial_text")
func get_setting_create_connect() -> bool: return get_setting("create_connect")
func get_setting_action_mode() -> ActionMode: return ActionMode[get_setting("action_mode")]
func get_setting_action_generate_mode() -> ActionGenerateMode: return ActionGenerateMode[get_setting("action_generate_mode")]
func get_setting_enable_connect_only_action() -> bool: return get_setting("enable_connect_only_action")
func get_setting_force_generate() -> bool: return get_setting("force_generate")
