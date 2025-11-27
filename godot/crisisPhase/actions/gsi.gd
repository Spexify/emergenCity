extends VRV_GSI
class_name EMC_GSI

@export var _gui_mngr: EMC_GUIMngr
@export var _stage_mngr: EMC_StageMngr
@export var _day_mngr: EMC_DayMngr

func request_trade_gui(npc_name: String) -> bool:
	var npc: EMC_NPC = _stage_mngr.get_NPC(npc_name)
	_gui_mngr.request_gui("Trade", [npc])
	return true

func npc_mood_less_than(npc_name: String, mood: String) -> bool:
	return true

func get_avatar_portrait() -> Texture2D:
	return load("res://assets/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png")
	
func get_npc_portrait(npc_name: String) -> Texture2D:
	return _stage_mngr.get_NPC(npc_name).npc_resource.get_comp(EMC_NPC_Descr).get_portrait()

func get_pitch(char_name: String) -> float:
	if char_name == "avatar":
		return EMC_Avatar.PITCH
	return _stage_mngr.get_NPC(char_name).npc_resource.get_comp(EMC_NPC_Conversation).get_pitch()

func get_period_count() -> int:
	return _day_mngr.get_period_count()
