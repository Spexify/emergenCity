extends Node
class_name EMC_NPC_Karma

enum Mood{
	BAD,
	SAD,
	MID,
	GOOD,
	HAPPY
}

## HACK: using a Vector2 instead of float allows karma to be passed by reference
## to the save comp, thus we don't need to manually update the karma value 
## for the save comp 
@export var karma : PackedFloat64Array = [0]

@onready var npc : EMC_NPC = $".."

func _init(dict: Dictionary) -> void:
	karma = dict.get("karma", [0])

func _ready() -> void:
	#Global.game_saved.connect(save)
	npc.add_comp(self)
	load_karma.call_deferred()

func load_karma() -> void:
	var tmp_karma: Variant = npc.get_comp(EMC_NPC_Save).get_res("Karma", TYPE_PACKED_FLOAT64_ARRAY)
	if tmp_karma == null:
		karma = [0]
		npc.get_comp(EMC_NPC_Save).add_res("Karma", karma)
	else:
		karma = tmp_karma
	
func get_karma_enum() -> Mood:
	if karma[0] < -0.8:
		return Mood.BAD
	elif karma[0] < -0.4:
		return Mood.SAD
	elif karma[0] < 0.0:
		return Mood.MID
	elif karma[0] < 0.4:
		return Mood.GOOD
	return Mood.HAPPY

func get_krama() -> float:
	return karma[0]

func add_karma(value: float) -> void:
	karma[0] += value
	karma[0] = clampf(karma[0], -1.0, 1.0)
