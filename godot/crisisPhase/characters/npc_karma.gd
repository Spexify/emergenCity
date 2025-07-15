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

var data: PackedFloat64Array = [0, 0]

@onready var npc : EMC_NPC = $".."

func _init(dict: Dictionary) -> void:
	karma = dict.get("karma", karma)
	mood = dict.get("mood", mood)

func _ready() -> void:
	#Global.game_saved.connect(save)
	npc.add_comp(self)
	load_karma.call_deferred()

func load_karma() -> void:
	var raw_data: Variant = npc.get_comp(EMC_NPC_Save).get_res("Karma", TYPE_PACKED_FLOAT64_ARRAY)
	if raw_data == null:
		npc.get_comp(EMC_NPC_Save).add_res("Karma", PackedFloat64Array([karma, mood]))
	else:
		if len(raw_data) == 2:
			karma = raw_data[0]
			if Global.was_crisis():
				mood = raw_data[1]
			else:
				npc.get_comp(EMC_NPC_Save).add_res("Karma", PackedFloat64Array([karma, mood]))

func set_mood(p_mood: float) -> void:
	mood = p_mood

func add_mood(p_mood: float) -> void:
	mood = clamp(mood + p_mood, 0, 4)
	
func sub_mood(p_mood: float) -> void:
	mood = clamp(mood - p_mood, 0, 4)

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
