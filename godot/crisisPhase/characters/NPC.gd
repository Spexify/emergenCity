extends CharacterBody2D
class_name EMC_NPC

signal clicked(p_NPC: EMC_NPC)

const TIME := ["morning", "noon", "evening"]

@onready var _sprite := $Sprite2D
@onready var _collision_circle := $CollisionCircle
@onready var _dialogue_hitbox := $DialogueHitbox

var _inventory : EMC_Inventory = EMC_Inventory.new(15)
var _score : int = 0

var _initial_inventory : Dictionary
var _stage : String
var _dialogue_pitch: float
var _positions : Dictionary
var _actions: Array[NPC_Action]
var _item_value: Dictionary
var _desires : Array[NPC_Desire]

########################################## PUBLIC METHODS ##########################################

func setup(p_name: String, args : Dictionary) -> void:
	name = p_name
	
	if args.has_all([ "stage", "pitch", "positions", "initial_items", "item_value", "desires", "actions" ]):
		_stage = args["stage"]
		_dialogue_pitch = args["pitch"]
		_positions = args["positions"]
		_initial_inventory = args["initial_items"]
		_item_value = args["item_value"]
		_desires.assign(args["desires"].values())
		_actions.assign(args["actions"])
	else:
		printerr("NPC Setup: Missing parameters!")
	
	position = _positions.get(_stage)
	
	for item_name : String in _initial_inventory.keys():
		for i : int in range(_initial_inventory[item_name] as int):
			_inventory.add_new_item(JsonMngr.item_name_to_id(item_name))
	
func _ready() -> void:
	var sprite_texture: CompressedTexture2D = load("res://res/sprites/characters/sprite_" + name.to_lower() + ".png")
	_sprite.texture = sprite_texture
	
	$AnimationPlayer.play("idle")
	
	if name == "Gerhard":
		for i in range(30):
			act()

func get_stage_name() -> String:
	return _stage

var t : int = 0

func act() -> String:
	var weights : Array[float]
	weights.assign(_actions.map(func (action : NPC_Action) -> int: return action.get_weight(TIME[t])))
	var action_key : NPC_Action = EMC_Util.pick_weighted_random_const(_actions, weights)
	
	#_happ.neglected()
	#_has_to_work.neglected()
	#_needs_water.neglected()
	
	_desires.all(func (desire : NPC_Desire) -> void : desire.neglected())
	
	action_key.execute(self)
	
	print(action_key._name)
	
	t+= 1
	if t >= 3:
		t = 0
		print()
	
	return action_key._name

func calulate_item_score_generic(items : Array[int], score : Dictionary, base_value : int) -> int:
	return items.reduce(
		func (accum : int, item : int) -> int:
			accum += score.get(JsonMngr.item_id_to_name(item), base_value)
			return accum, 0)

func calculate_trade_score(items : Array[int]) -> int:
	return calulate_item_score_generic(items, _item_value, 1)

func calculate_inventory_score(score : Dictionary = _item_value, base_value : int = 1) -> int:
	return calulate_item_score_generic(_inventory.get_all_items_as_id(), score, base_value)
	
#func calculate_work_score() -> int:
	#return (calulate_item_score_generic(_inventory.get_all_item_slots_as_id(), _brain["work"]["has"], 1)
			#- calulate_item_score_generic(_inventory.get_all_items_as_id(), _brain["work"]["needs"], 0))
			#
#func normalize_work_score(value : float) -> float:
	#var max : float =_brain["work"]["has"].values().max() * _inventory._slot_cnt
	#var min : float = _brain["work"]["needs"].values().max() * _inventory._slot_cnt
	#return int((value as float + min)*(150.0/(min + max)))

func get_inventory() -> EMC_Inventory:
	return _inventory

func deactivate() -> void:
	hide()
	_collision_circle.disabled = true
	_dialogue_hitbox.disabled = true

func activate() -> void:
	show()
	_collision_circle.disabled = false
	_dialogue_hitbox.disabled = false

func _to_string() -> String:
	return str(name) + " @ " + str(position);

########################################## PRIVATE METHODS #########################################

func _on_dialogue_hit_box_pressed() -> void:
	clicked.emit(self)

#************************************** Action Methods *********************************************

func get_item(args : Dictionary) -> void:
	for i in range(args.get("count")):
		_inventory.add_new_item(JsonMngr.item_name_to_id(args.get("name")))

func get_random_item(args : Dictionary) -> void:
	for i in range(args.get("count")):
		_inventory.add_new_item(JsonMngr._id_to_name.keys().pick_random())

func remove_item(args : Dictionary) -> void:
	_inventory.remove_item(JsonMngr.item_name_to_id(args.get("name")), args.get("count"))
	
func exchange_items(args : Dictionary) -> void:
	var items : Array[EMC_Item] = _inventory.filter_items(EMC_Inventory.filter_ids(args.get("in").keys().map(func (item_name : String) -> int: return JsonMngr.item_name_to_id(item_name))))

	var count : int = 0
	while count < args.get("max_count") and items.size() > 0:
		var item_index : int = range(items.size()).pick_random()
		var item : EMC_Item = items.pop_at(item_index)
		_inventory.remove_specific_item(item)
		
		_score += args.get("in").get(JsonMngr.item_id_to_name(item.get_ID()))
		count += 1
		
	while _score > 0:
		var item_name : String = args.get("out").keys().pick_random()
		if _score - args.get("out")[item_name] > 0:
			_score -= args.get("out")[item_name]
			_inventory.add_new_item(JsonMngr.item_name_to_id(item_name))
		else:
			break

func change_stage(args : Dictionary) -> void:
	_stage = args.get("stage_name")
	position = _positions.get(_stage)

########################################## HELPER CLASSES #########################################

class NPC_Desire:
		
	func reinforce(value: int) -> int:
		return value
		
	func neglected() -> void:
		pass
		
	func choosen() -> void:
		pass


class NPC_Accumulator_Desire:
	extends NPC_Desire
	
	var accum: int = 0
	var _increase: int
	
	func _init(p_increase : int) -> void:
		_increase = p_increase
	
	func neglected() -> void:
		accum += _increase
	
	func choosen() -> void:
		accum = 0
	
	func reinforce(value: int) -> int:
		return value + accum

class NPC_Inventory_Desire:
	extends NPC_Desire
	
	var _item_score : Dictionary
	var _max_reinfroce : int
	var _npc : EMC_NPC
	var _accel : float
	var _base_value : int
	
	var accum : int = 0
	
	func _init(p_item_score : Dictionary, p_max_reinforce : int, p_npc : EMC_NPC, p_base_value : int = 0, p_accel : float = 1.0) -> void:
		_item_score = p_item_score
		_max_reinfroce = p_max_reinforce
		_npc = p_npc
		_accel = p_accel
		_base_value = p_base_value
	
	func reinforce(value: int) -> int:
		return value + accum
		
	func neglected() -> void:
		accum += floori(_npc.calculate_inventory_score(_item_score, _base_value) as float * _accel)
		accum = clampi(accum, 0, _max_reinfroce)
		
	func choosen() -> void:
		accum = 0

class NPC_Action:
	var _desire: NPC_Desire
	var _consequnces: Dictionary
	var _routine: Dictionary
	var _name: String

	func _init(p_desire: NPC_Desire, p_consequnces: Dictionary, p_routine: Dictionary, p_name : String = "none") -> void:
		_desire = p_desire
		_consequnces = p_consequnces
		_routine = p_routine
		_name = p_name
		
	func get_weight(time: String) -> int:
		return _desire.reinforce(_routine.get(time))
		
	func execute(npc: EMC_NPC) -> bool:
		var result : bool = true
		_desire.choosen()
		for key : String in _consequnces.keys():
			Callable(npc, key).call(_consequnces[key])
		return result
