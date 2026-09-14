extends "editor_settings_helper_base.gd"


enum ActionMode{
	COPY, ##クリップボードにコピー
	GENERATE, ##生成されます。位置については[code]ActionGenerateMode[/code]
}
enum ActionGenerateMode{
	BOTTOM, ##最下部
	NEXT, ##次にインデントが無い行
}


func _add_settings_initialized() -> void:
	##[code]action_mode[/code]が[code]ActionMode.GENERATE[/code]の時、生成時の上の関数との行間隔
	add_setting("line_space", 2, TYPE_INT, PROPERTY_HINT_RANGE, "0, 1, 1, or_greater")
	##戻り型。空でも可
	add_setting("type", "void", TYPE_STRING)
	
	add_setting("initial_text", "pass", TYPE_STRING)
	##[code]action_mode[/code]が[code]ActionMode.GENERATE[/code]の時、生成時に自動で[code]initial_text[/code]を選択する
	add_setting("select_initial_text", true, TYPE_BOOL)
	##connect()を作成する。[br][note][code]action_mode[/code]が何の場合でもこの設定は機能します。[/note]
	add_setting("create_connect", true, TYPE_BOOL)
	
	add_setting("action_mode", ActionMode.find_key(ActionMode.GENERATE), TYPE_STRING, PROPERTY_HINT_ENUM, ",".join(ActionMode.keys()) )
	
	add_setting("action_generate_mode", ActionGenerateMode.find_key(ActionGenerateMode.NEXT), TYPE_STRING, PROPERTY_HINT_ENUM, ",".join(ActionGenerateMode.keys()) )
	##connect()作成のみのアクションを新たに追加する
	add_setting("enable_connect_only_action", true, TYPE_BOOL)
	##[code]action_mode[/code]が[code]ActionMode.GENERATE[/code]の時、すでにその名前の関数がある場合でも作成する
	add_setting("force_generate", false, TYPE_BOOL)




func get_setting_line_space() -> int: return get_setting("line_space")
func get_setting_type() -> String: return get_setting("type")
func get_setting_initial_text() -> String: return get_setting("initial_text")
func get_setting_select_initial_text() -> bool: return get_setting("select_initial_text")
func get_setting_create_connect() -> bool: return get_setting("create_connect")
func get_setting_action_mode() -> ActionMode: return ActionMode[get_setting("action_mode")]
func get_setting_action_generate_mode() -> ActionGenerateMode: return ActionGenerateMode[get_setting("action_generate_mode")]
func get_setting_enable_connect_only_action() -> bool: return get_setting("enable_connect_only_action")
func get_setting_force_generate() -> bool: return get_setting("force_generate")
