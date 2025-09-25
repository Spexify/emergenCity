extends Node
class_name EMC_NPC_Karma

enum Mood{
	BAD = 0,
	SAD = 1,
	MID = 2,
	GOOD = 3,
	HAPPY = 4
}

## HACK: using a Vector2 instead of float allows karma to be passed by reference
## to the save comp, thus we don't need to manually update the karma value 
## for the save comp 
@export var karma: float = 0
@export var mood: float = Mood.MID

var _save: EMC_NPC_Save

@onready var npc : EMC_NPC = $".."

func _init(dict: Dictionary) -> void:
	karma = dict.get("karma", karma)
	mood = dict.get("mood", mood)

func _ready() -> void:
	#Global.game_saved.connect(save)
	npc.add_comp(self)
	load_karma.call_deferred()

func load_karma() -> void:
	_save = npc.get_comp(EMC_NPC_Save)
	if not _save:
		printerr("No Save comp")
		return
	
	var raw_karma: Variant = _save.get_res("karma", TYPE_FLOAT)
	if raw_karma is float and not is_nan(raw_karma as float):
		karma = raw_karma
	else:
		_save.add_res("karma", karma)
	
	if Global.get_game_state() == Global.State.CRISIS:
		var raw_mood: Variant = _save.get_res("mood", TYPE_FLOAT)
		if raw_mood is float and not is_nan(raw_mood as float):
			mood = raw_mood
			return
	_save.add_res("mood", mood)

func set_mood(p_mood: float) -> void:
	mood = p_mood
	_save.add_res("mood", mood)

func add_mood(p_mood: float) -> void:
	mood = clamp(mood + p_mood, 0, 4)
	_save.add_res("mood", mood)
	
func sub_mood(p_mood: float) -> void:
	mood = clamp(mood - p_mood, 0, 4)
	_save.add_res("mood", mood)

func get_mood() -> Mood:
	return ceili(mood) as Mood

func mood_less_than(p_mood: int) -> bool:
	return get_mood() < p_mood
	
func mood_greater_than(p_mood: int) -> bool:
	return get_mood() > p_mood

func get_krama() -> float:
	return karma

func add_karma(value: float) -> void:
	karma += value
	karma = clampf(karma, -1.0, 1.0)
	_save.add_res("karma", karma)
