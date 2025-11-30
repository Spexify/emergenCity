extends VRV_GSI
class_name EMC_GSI

@export var _gui_mngr: EMC_GUIMngr
@export var _stage_mngr: EMC_StageMngr
@export var _day_mngr: EMC_DayMngr
@export var _score: EMC_Scoreboard
@export var _npc_mngr: EMC_NPC_Mngr

func request_trade_gui(npc_name: String) -> bool:
	var npc: EMC_NPC = _stage_mngr.get_NPC(npc_name)
	_gui_mngr.request_gui("Trade", [npc])
	return true

func npc_mood_less_than(npc_name: String, mood: String) -> bool:
	return true

func get_avatar_portrait() -> Texture2D:
	return load("res://assets/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png")
	
func get_npc_portrait(npc_name: String) -> Texture2D:
	return _npc_mngr.get_NPC(npc_name).npc_resource.get_comp(EMC_NPC_Descr).get_portrait()

func get_pitch(char_name: String) -> float:
	if char_name == "avatar":
		return EMC_Avatar.PITCH
	if char_name.to_lower() == "erzähler":
		return 1.0
	return _npc_mngr.get_NPC(char_name).npc_resource.get_comp(EMC_NPC_Conversation).get_pitch()

func get_period_count() -> int:
	return _day_mngr.get_period_count()

func set_tutorial(value: bool) -> bool:
	Global._tutorial_done = value
	return value
	
func request_gui(gui_name: String, args: Array) -> bool:
	_gui_mngr.request_gui(gui_name, args)
	return true

func add_score(log_name: String, context: Dictionary) -> bool:
	_score.add_score(log_name, context)
	return true
