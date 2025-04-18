extends EMC_NPC_Interaction_Option
class_name EMC_NPC_Trading

@export var _inventory: EMC_Inventory
@export var _item_preference: Dictionary
#@export var _tips: Array[String]
#@export var _tip_ratio: int
@export var _response: Dictionary
@export var _bottom: float = -0.6
@export var _low: float = -0.3
@export var _mid: float = 0.0
@export var _high: float = 0.3
@export var _top: float = 0.6

@export var _karma_weight: float = 1.0
@export var _value_weight: float = 1.0
@export var _decision_noise: float = 0.0

@onready var npc: EMC_NPC = $"../.."

#var _resp_bottom: Array[String]
#var _resp_top: Array[String]
#var _resp_low: Array[String]
#var _resp_mid: Array[String]
#var _resp_high: Array[String]

var _gui_mngr: EMC_GUIMngr
var _day_mngr: EMC_DayMngr
var _initial_inventory: Dictionary

var _karma_comp: EMC_NPC_Karma

func _init(dict: Dictionary) -> void:
	_initial_inventory = dict.get("inventory", {})
	_item_preference = dict.get("preferences", {})
	
	_response = dict.get("response", {})
	#_resp_bottom.assign(_response.get("bottom", []))
	#_resp_top.assign(_response.get("top", []))
	#_resp_low.assign(_response.get("low", []))
	#_resp_mid.assign(_response.get("mid", []))
	#_resp_high.assign(_response.get("high", []))
	
	#_tips.assign(dict.get("tip", []))
	#_tip_ratio = (dict.get("tip_ratio", 5))
	
	_bottom = dict.get("bottom", _bottom)
	_low = dict.get("low", _low)
	_mid = dict.get("mid", _mid)
	_high = dict.get("high", _high)
	_top = dict.get("top", _top)
	
	_karma_weight = dict.get("karma_weight", 1.0)
	_value_weight = dict.get("value_weight", 1.0)
	_decision_noise = dict.get("noise", 0.0)

func _ready() -> void:
	_gui_mngr = npc.get_gui_mngr()
	_day_mngr = npc.get_day_mngr()
	npc.add_comp(self)
	
	## INFO Needs to be called deferred to ensure that all components are loaded
	load_dependencies.call_deferred()

#func _accquire_karma_comp() -> void:
	#_karma_comp = npc.get_comp(EMC_NPC_Descr)

func get_title() -> String:
	return "Handeln"

func run() -> void:
	_gui_mngr.request_gui("Trade", [npc])

func get_inventory() -> EMC_Inventory:
	return _inventory

## Loads dependencies, which include the inventory and karam component
## Needs to be called after all components are loaded
func load_dependencies() -> void:
	_karma_comp = npc.get_comp(EMC_NPC_Karma)
	
	_inventory = npc.get_comp(EMC_NPC_Save).get_res("Inventory", EMC_Inventory)
	if _inventory == null or not Global.was_crisis():
		_inventory = EMC_Inventory.new(18)
		for item_name : String in _initial_inventory.keys():
			for i : int in range(_initial_inventory[item_name] as int):
				_inventory.add_new_item(JsonMngr.item_name_to_id(item_name))
		
		npc.get_comp(EMC_NPC_Save).add_res("Inventory", _inventory)

func calulate_item_score_generic(items : Array[EMC_Item]) -> float:
	return items.reduce(
		func (accum : int, item : EMC_Item) -> int:
			var value_comp := item.get_comp(EMC_IC_Value)
			accum += _item_preference.get(JsonMngr.item_id_to_name(item.get_id()), 1) * (value_comp.get_value() if value_comp != null else 1)
			return accum, 0)

func calculate_trade_score(sell_items : Array[EMC_Item], buy_items : Array[EMC_Item]) -> float:
	var sell_value := calulate_item_score_generic(sell_items)
	var buy_value := calulate_item_score_generic(buy_items)
	
	if sell_value == 0 and buy_value == 0:
		return -1.0
	
	var trade_score := (sell_value - buy_value) / maxf(sell_value, buy_value)

	return trade_score * _value_weight + _karma_comp.get_krama() * _karma_weight + randf_range(-_decision_noise, _decision_noise)
	
func get_mood_texture(trade_score: float, mood_texture: AtlasTexture) -> Texture2D:
	if trade_score < _bottom:
		mood_texture.set_region(Rect2(256, 0, 64, 64))
	elif trade_score < _low:
		mood_texture.set_region(Rect2(192, 0, 64, 64))
	elif trade_score < _high:
		mood_texture.set_region(Rect2(128, 0, 64, 64))
	elif trade_score < _top:
		mood_texture.set_region(Rect2(64, 0, 64, 64))
	else:
		mood_texture.set_region(Rect2(0, 0, 64, 64))
		
	return mood_texture
	
func get_response(item: EMC_Item) -> String:
	var list: Array[String] = ["Interessant"]
	var base: Array[String]
	base.assign(_response.get("BASE", ["Hmm mal Schaun"]))
	var item_name: String = JsonMngr.item_id_to_name(item.get_id())
	
	if _item_preference.has(item_name):
		list.append("Oh das Items gefällt mir.")
		if _item_preference.get(item_name) >= 2:
			list.append("Ich mag " + item.name + " sehr.")
			
	if _response.has(item_name):
		list.append_array(_response[item_name])

	if item.get_comp(EMC_IC_Food):
		list.append_array(_response.get("FOOD", []))
		
	if item.get_comp(EMC_IC_Drink):
		list.append_array(_response.get("DRINK", []))
		
	if item.get_comp(EMC_IC_Unpalatable):
		list.append_array(_response.get("UNPALATABLE", []))
	
	#var value_comp := item.get_comp(EMC_IC_Value)
	#if (value_comp.get_value() if value_comp != null else 1) > 1:
		#list.append("Oh diese Item ist recht wertvoll")
		
	return [list, base].pick_random().pick_random()
	#if trade_score < _bottom:
		#if range(_tip_ratio).pick_random():
			#if not _resp_bottom.is_empty():
				#return _resp_bottom.pick_random()
		#else:
			#if not _tips.is_empty():
				#return _tips.pick_random()
		#return "Das ist eine Scherz"
	#elif trade_score < _low:
		#if range(_tip_ratio).pick_random():
			#if not _resp_low.is_empty():
				#return _resp_low.pick_random()
		#else:
			#if not _tips.is_empty():
				#return _tips.pick_random()
		#return "Gefällt mir nicht"
	#elif trade_score < _mid:
		#if range(_tip_ratio).pick_random():
			#if not _resp_mid.is_empty():
				#return _resp_mid.pick_random()
		#else:
			#if not _tips.is_empty():
				#return _tips.pick_random()
		#return "Wenn ich muss"
	#elif trade_score < _high:
		#if range(_tip_ratio).pick_random():
			#if not _resp_high.is_empty():
				#return _resp_high.pick_random()
		#else:
			#if not _tips.is_empty():
				#return _tips.pick_random()
		#return "Gefällt mir"
	#elif trade_score < _top:
		#if range(_tip_ratio).pick_random():
			#if not _resp_top.is_empty():
				#return _resp_top.pick_random()
		#else:
			#if not _tips.is_empty():
				#return _tips.pick_random()
		#return "Gefällt mir sehr"
	#else:
		#if not _tips.is_empty() and not range(_tip_ratio).pick_random():
			#return _tips.pick_random()
		#return "Du bist zu gut zu mir"
		
func will_deal(trade_score: float) -> bool:
	if trade_score * _value_weight + _karma_comp.get_krama() * _karma_weight + randf_range(-_decision_noise, _decision_noise) >= _low:
		return false
	else:
		return true
		
func deal(trade_score: float) -> void:
	trade_score -= _karma_weight * _karma_comp.get_krama()
	if trade_score < _bottom:
		_karma_comp.add_karma(-0.3)
	elif trade_score < _low:
		_karma_comp.add_karma(-0.2)
	elif trade_score < _mid:
		_karma_comp.add_karma(-0.1)
	elif trade_score < _high:
		_karma_comp.add_karma(0.1)
	elif trade_score < _top:
		_karma_comp.add_karma(0.2)
	else:
		_karma_comp.add_karma(0.3)
