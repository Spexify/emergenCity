extends EMC_NPC_Interaction_Option
class_name EMC_NPC_Conversation

const FLAG_DAY_SEEN     = 1 << 0  # 01
const FLAG_PURPOSE_SEEN = 1 << 1  # 10

@export var npc_pitch: float = 1.0
@export var tags: Array[String]
@export var day: int = 0
@export var dialogue_flags: int = 0

@onready var npc: EMC_NPC = $"../.."

var _gui_mngr: EMC_GUIMngr
var _stage_mngr: EMC_StageMngr
var _checker: EMC_ActionConstraints

var _save: EMC_NPC_Save

var _small_talk: Array[VRV_Dialogue]
var _day_dialogues: Dictionary[String, Array]
var _purpose: Dictionary[String, VRV_Dialogue]
var _event: Dictionary[String, VRV_Dialogue]

func _init(dict: Dictionary) -> void:
	npc_pitch = dict.get("pitch", 1.0)
	var npc_paths: Dictionary[String, String]
	npc_paths.assign(dict.get("paths", {}))
	_load_dialoges(npc_paths)

func _ready() -> void:
	_gui_mngr = npc.get_gui_mngr()
	_stage_mngr = npc.get_stage_mngr()
	_checker = npc.get_act_cond()
	
	npc.get_day_mngr().period_increased.connect(reset)
	
	npc.add_comp(self)
	load_save.call_deferred()

## TODO loading day dialogues
func _load_dialoges(npc_paths: Dictionary[String, String]) -> void:
	if npc_paths.has("day"):
		_day_dialogues["0"] = _load_dir(npc_paths["day"]).values()
	if  npc_paths.has("event"):
		_event = _load_dir(npc_paths["purpose"])
	if npc_paths.has("purpose"):
		_purpose = _load_dir(npc_paths["purpose"])
	if npc_paths.has("small_talk"):
		_small_talk = _load_dir(npc_paths["small_talk"]).values()
	else:
		_small_talk = _load_dir("res://resources/dialogues/small_talk/").values()

func _load_dir(path: String) -> Dictionary[String, VRV_Dialogue]:
	var result: Dictionary[String, VRV_Dialogue]
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".vrv"):
				var raw_dialoge := ResourceLoader.load(path + file_name, "VRV_Dialogue")
				if raw_dialoge is VRV_Dialogue:
					result[file_name] = raw_dialoge
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
	return result

func load_save() -> void:
	_save = npc.get_comp(EMC_NPC_Save)
	if not _save:
		printerr("No Save comp")
		return
	
	if Global.get_game_state() == Global.State.CRISIS:
		var raw_day: Variant = _save.get_res("conv_day", TYPE_INT)
		if raw_day is int and not is_nan(raw_day as int):
			day = raw_day
		else:
			_save.add_res("conv_day", day)
			
		var raw_flags: Variant = _save.get_res("conv_flags", TYPE_INT)
		if raw_flags is int and not is_nan(raw_flags as int):
			dialogue_flags = raw_flags
		else:
			_save.add_res("conv_flags", dialogue_flags)
	else:
		_save.add_res("conv_day", day)
		_save.add_res("conv_flags", dialogue_flags)

func get_title() -> String:
	return "Reden"

func reset(_tmp: int) -> void:
	dialogue_flags = 0
	_save.add_res("conv_flags", dialogue_flags)

func run() -> void:
	var npc_name : String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
	#var stage_name: String = npc.get_comp(EMC_NPC_Stage).get_stage_name()
	
	var purpose: String = ""
	
	# Purpose not yet seen
	if (dialogue_flags & FLAG_PURPOSE_SEEN == 0
		and not purpose.is_empty()
		and _purpose.has(purpose)):
		
		var dialogue: VRV_Dialogue = _purpose.get(purpose)
		dialogue._start_npc = npc_name
		_gui_mngr.request_gui("DialogueGui", [dialogue])
		dialogue_flags |= FLAG_PURPOSE_SEEN
		_save.add_res("conv_flags", dialogue_flags)
	
	# Day Dialoge not yet seen
	elif dialogue_flags & FLAG_DAY_SEEN == 0 and _day_dialogues.has("0"):
		var dialogues: Array[VRV_Dialogue]
		if not _day_dialogues.has(str(day)):
			day = 0
			_save.add_res("conv_day", day)
		dialogues.assign(_day_dialogues[str(day)])
		var dialogue: VRV_Dialogue = dialogues.filter(
			func (dia: VRV_Dialogue) -> bool: return dia.check_start()).pick_random()
		
		dialogue._start_npc = npc_name
		_gui_mngr.request_gui("DialogueGui", [dialogue])
		dialogue_flags |= FLAG_DAY_SEEN
		_save.add_res("conv_flags", dialogue_flags)
		day += 1
		_save.add_res("conv_day", day)
	else:
		var dialogue: VRV_Dialogue = _small_talk.pick_random()
		dialogue._start_npc = npc_name
		_gui_mngr.request_gui("DialogueGui", [dialogue])

func get_pitch() -> float:
	return npc_pitch

## TODO: tag ramove functionality
func add_tag(tag: String) -> void:
	tags.append(tag)

## TODO: tag ramove functionality
func has_tag(tag: String) -> bool:
	if tag in tags:
		tags.erase(tag)
		return true
	return false

func remove_tag(tag: String) -> void:
	tags.erase(tag)
