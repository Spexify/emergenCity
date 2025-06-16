extends Node
class_name EMC_Scoreboard

@export var spawn_rect: Rect2i = Rect2i(100, 200, 100, 100)

@onready var canvas_layer: CanvasLayer = $CanvasLayer

enum ScoreCat{
	PREPAREDNESS,
	SELF_SUFFICIENCY,
	COMMUNITY,
	RESOURCE_EFFICIENCY,
	INFOMRATION
}

const score_cat_to_text: Dictionary = {
	ScoreCat.PREPAREDNESS: "Vorbereitung",
	ScoreCat.SELF_SUFFICIENCY: "Selbsterhaltung",
	ScoreCat.COMMUNITY: "Gesellschaft",
	ScoreCat.RESOURCE_EFFICIENCY: "Nachhaltigkeit",
	ScoreCat.INFOMRATION: "Wissen"
}

const score_cat_to_color: Dictionary = {
	ScoreCat.PREPAREDNESS: EMC_Palette.DARK_BLUE,
	ScoreCat.SELF_SUFFICIENCY: EMC_Palette.LIGHT_RED,
	ScoreCat.COMMUNITY: EMC_Palette.LIGHT_YELLOW,
	ScoreCat.RESOURCE_EFFICIENCY: EMC_Palette.LIGHT_GREEN,
	ScoreCat.INFOMRATION: EMC_Palette.LIGHT_BLUE
}

const score_cat_to_multiplier: Dictionary = {
	ScoreCat.PREPAREDNESS: 1,
	ScoreCat.SELF_SUFFICIENCY: 0.5,
	ScoreCat.COMMUNITY: 1,
	ScoreCat.RESOURCE_EFFICIENCY: 0.5,
	ScoreCat.INFOMRATION: 0.5
}

const win_lose_multiplier: Dictionary = {
	true: 1,
	false: 0.7
}

class ActionLog extends Resource:
	@export var descr: String = "NONAME"
	@export var rule: Callable = ScoreRule.Default
	@export var context: Dictionary = {}
	@export var eval: Dictionary = {}
	
	func setup(_descr: String, _rule: Callable = ScoreRule.Default) -> ActionLog:
		self.descr = _descr
		self.rule = _rule
		return self
	
	# Calulates the score and returns duplicate
	func dup_calculate() -> ActionLog:
		self.eval = self.rule.call(self)
		var result := ActionLog.new()
		result.context = self.context
		result.eval = self.eval
		return result

static var state: Dictionary = {
	"bbk": false,
	"help": false,
	"radio": false,
}

class ScoreRule:
	static var Default: Callable = (func (log: ActionLog) -> Dictionary: return {ScoreCat.SELF_SUFFICIENCY: 10})
	# TODO: Make Score dependent on items used nd produced
	static var Cook: Callable = (func (log: ActionLog) -> Dictionary: return {ScoreCat.SELF_SUFFICIENCY: 10})
	static var Shower: Callable = (func (log: ActionLog) -> Dictionary: 
		return {
			ScoreCat.SELF_SUFFICIENCY: 10 + 10 * log.context["water"],
			ScoreCat.RESOURCE_EFFICIENCY: 10 * log.context["soap"]
		})
	static var BBK: Callable = (func (log: ActionLog) -> Dictionary: 
		if not EMC_Scoreboard.state["bbk"]:
			EMC_Scoreboard.state["bbk"] = true
			return {ScoreCat.INFOMRATION: 10}
		return {}
		)
	# TODO: radio boolena value
	static var Radio: Callable = (func (log: ActionLog) -> Dictionary:
		if not EMC_Scoreboard.state["radio"]:
			EMC_Scoreboard.state["radio"] = true
			return {
				ScoreCat.INFOMRATION: 10,
				ScoreCat.RESOURCE_EFFICIENCY: 10 * log.context["batteries"]
			}
		return {
			ScoreCat.INFOMRATION: 10 * log.context["batteries"]
		})
	static var Reservoir: Callable = (func (log: ActionLog) -> Dictionary: 
		return {
			ScoreCat.PREPAREDNESS: 10 * log.context["fill"],
			ScoreCat.RESOURCE_EFFICIENCY: 10 - 10 * log.context["fill"]
		})
	
## WARNING: returns reference to the same object
var name_to_log: Dictionary = {
	"cook": ActionLog.new().setup("Kochen", ScoreRule.Cook),
	"sleep": ActionLog.new().setup("Schlafen", ScoreRule.Default),
	"shower": ActionLog.new().setup("Duschen", ScoreRule.Shower),
	"bbk": ActionLog.new().setup("Broschüre", ScoreRule.BBK),
	"radio": ActionLog.new().setup("Radio", ScoreRule.Radio),
	"reservoir": ActionLog.new().setup("Reservoir", ScoreRule.Reservoir),
}

## Prepare Phase Total
var num_run: int = 0
var prep_tot_items: Dictionary = {}
var tot_difficulty: Dictionary = {
	OverworldStatesMngr.Difficulty.TUTORIAL: 0,
	OverworldStatesMngr.Difficulty.EASY: 0,
	OverworldStatesMngr.Difficulty.MEDIUM: 0,
	OverworldStatesMngr.Difficulty.HARD: 0
}
var tot_upgrades_equipped: Dictionary = {}
## Prepare Phase Sequence
#var prep_seq_items: Array[Dictionary] = [{}]
#var seq_difficulty: Array = []
#var seq_upgrades_bougth: Dictionary = { 0: [] }
#var seq_upgrades_equipped: Array = [ [ ] ]

var current_difficulty: EMC_OverworldStatesMngr.Difficulty
# Format: { day: [ACTIONLOG, ACTIONLOG, ACTIONLOG], day: [...], ... }
var score_log: Dictionary

@export var _day_mngr: EMC_DayMngr

func start_run(_inventory: EMC_Inventory, difficulty: EMC_OverworldStatesMngr.Difficulty, _upgrades: Array[int]) -> void:
	num_run += 1
	for item: EMC_Item in _inventory.get_items():
		if item != null:
			var item_name: String = JsonMngr.item_id_to_name(item.get_id())
			if prep_tot_items.has(item_name):
				prep_tot_items[item_name] += 1
			else:
				prep_tot_items[item_name] = 1
			
	tot_difficulty[difficulty] += 1
	current_difficulty = difficulty
	
	for id: int in _upgrades:
		if tot_upgrades_equipped.has(id):
			tot_upgrades_equipped[id] += 1
		else:
			tot_upgrades_equipped[id] = 1

func add_score(log_name: String, context: Dictionary = {}) -> void:
	var day: int = _day_mngr.get_current_day()
	var log: ActionLog = name_to_log.get(log_name, ActionLog.new())
	log.context = context
	log = log.dup_calculate()
	if score_log.has(day):
		score_log[day].append(log)
	else:
		score_log[day] = [log]
		
	for cat: ScoreCat in log.eval:
		if log.eval[cat] > 0:
			animate_score(log.eval[cat], score_cat_to_color[cat])
	
func get_day_score() -> int:
	var score: int = 0
	if score_log.has(_day_mngr.get_current_day()-1):
		for log: ActionLog in score_log[_day_mngr.get_current_day()-1]:
			score += log.eval.values().reduce(func (acc: int, v: int) -> int: return acc + v)
			
		return score
	return 0

func get_day_summary() -> Dictionary:
	var result: Dictionary = {
		ScoreCat.PREPAREDNESS: 0,
		ScoreCat.SELF_SUFFICIENCY: 0,
		ScoreCat.COMMUNITY: 0,
		ScoreCat.RESOURCE_EFFICIENCY: 0,
		ScoreCat.INFOMRATION: 0
	}
	if score_log.has(_day_mngr.get_current_day()-1):
		for log: ActionLog in score_log[_day_mngr.get_current_day()-1]:
			for cat: ScoreCat in log.eval.keys():
				result[cat] += log.eval[cat]
	
	return result

func get_game_score() -> int:
	var total_score: Array
	for day_score: Array in score_log.values():
		total_score.append_array(day_score)
	
	return total_score.reduce(
		func (acc: int, v: ActionLog) -> int:
			return acc + (v.eval.values().reduce(
				func(acc: int, v: int) -> int: 
					return acc + v)), 0)
	
func get_game_summary() -> Dictionary:
	var result: Dictionary = {
		ScoreCat.PREPAREDNESS: 0,
		ScoreCat.SELF_SUFFICIENCY: 0,
		ScoreCat.COMMUNITY: 0,
		ScoreCat.RESOURCE_EFFICIENCY: 0,
		ScoreCat.INFOMRATION: 0
	}
	
	var total_score: Array
	for day_score: Array in score_log.values():
		total_score.append_array(day_score)
	
	for log: ActionLog in total_score:
		for cat: ScoreCat in log.eval.keys():
			result[cat] += log.eval[cat]
	
	return result
	
func calculate_e_coins(p_won: bool) -> int:
	var e_coins: float = 0
	var summary: = get_game_summary()
	for cat: ScoreCat in summary:
		e_coins += summary[cat] * score_cat_to_multiplier[cat]
	
	return int(e_coins * win_lose_multiplier[p_won])

func animate_score(value: int, color: Color) -> void:
	var number: Label = Label.new()
	var x: int = randi_range(spawn_rect.position.x, spawn_rect.position.x+spawn_rect.size.x)
	var y: int = randi_range(spawn_rect.position.y, spawn_rect.position.y+spawn_rect.size.y)
	number.global_position = Vector2(x, y)
	number.text = str(value)
	number.label_settings = LabelSettings.new()
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 25
	
	canvas_layer.add_child.call_deferred(number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	tween.tween_property(
		number, "position:y", number.position.y - 24, 1.0
	)
	tween.tween_property(
		number, "label_settings:font_size", 50, 0.5
	)
	
	# TODO: Add Sound
	
	await tween.finished
	number.queue_free()
