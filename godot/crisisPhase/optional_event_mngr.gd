extends Node
class_name EMC_OptionalEventMngr


## Tuple class, you're welcome to access its public (!) members directly
class SpawnNPCs:
	var stage_name: String
	var NPC_name: String
	var pos: Vector2


## Tuple class, you're welcome to access its public (!) members directly
class SpawnTiles:
	var stage_name: String
	var tilemap_pos: Vector2i
	var atlas_coord: Vector2i
	var tiles_cols: int
	var tiles_rows: int
	var overwrite_existing_tiles: bool = true


## Tuple class, you're welcome to access its public (!) members directly
class Event:
	var name: String
	var propability: int #Weighted numbers, should be used between 1 and 10
	var descr: String
	var announce_only_on_radio: bool
	var active_periods: int
	var constraints: Dictionary
	var consequences: Dictionary
	var spawn_NPCs_arr: Array[SpawnNPCs]
	var spawn_tiles_arr: Array[SpawnTiles]
	
	func _init(p_name: String, p_propability: int, p_descr: String, p_announce_only_on_radio: bool,
	p_active_periods: int, p_constraints: Dictionary, p_consequences: Dictionary, 
	p_spawn_NPCs_arr: Array[SpawnNPCs], p_spawn_tiles_arr: Array[SpawnTiles]) -> void:
		name = p_name
		propability = p_propability
		descr = p_descr
		announce_only_on_radio = p_announce_only_on_radio
		active_periods = p_active_periods
		constraints = p_constraints
		consequences = p_consequences
		spawn_NPCs_arr = p_spawn_NPCs_arr
		spawn_tiles_arr = p_spawn_tiles_arr


#OEP = Optional Event countdown
const OEC_LOWER_BOUND : int = 2
const OEC_UPPER_BOUND : int = 4 
#const OE_ACTIVE_PERIODS: int = 2 #Amount of periods that an event stays active

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _opt_event_probability_countdown : int
var _tooltip_GUI: EMC_TooltipGUI
var _active_events: Array[Event]
var _constraints: EMC_ActionConstraints
var _consequences: EMC_ActionConsequences

########################################## PUBLIC METHODS ##########################################
## Constructor
func _init(p_tooltip_GUI: EMC_TooltipGUI) -> void:
	_tooltip_GUI = p_tooltip_GUI
	_opt_event_probability_countdown = _rng.randi_range(OEC_LOWER_BOUND, OEC_UPPER_BOUND)


func get_active_events() -> Array[Event]:
	return _active_events


func set_constraints(p_constraints: EMC_ActionConstraints) -> void:
	_constraints = p_constraints


func set_consequences(p_consqeuences: EMC_ActionConsequences) -> void:
	_consequences = p_consqeuences

########################################## PRIVATE METHODS #########################################
func _on_day_mngr_period_ended(p_new_period: EMC_DayMngr.DayPeriod) -> void:
	#See if event should end
	for event: Event in _active_events:
		event.active_periods -= 1
		if event.active_periods == 0:
			_active_events.erase(event)
	
	#See if new event should be started
	_opt_event_probability_countdown -= 1
	if _opt_event_probability_countdown == 0:
		_create_new_optional_event(p_new_period)
		_opt_event_probability_countdown = _rng.randi_range(OEC_LOWER_BOUND, OEC_UPPER_BOUND)


func _create_new_optional_event(p_new_period: EMC_DayMngr.DayPeriod) -> void:
	var possible_opt_events := JsonMngr.get_possible_opt_events(_constraints)
	
	#Dependend on the propability choose one to activate
	var indices: Array[int]
	
	for event_idx in possible_opt_events.size():
		var event: Event = possible_opt_events[event_idx]
		for i in event.propability:
			indices.append(event_idx)
	
	var chosen_event: Event = possible_opt_events[indices.pick_random()]
	
	#Activate the chosen event
	_active_events.append(chosen_event)
	print("Event started:" + chosen_event.name) ##Test
	if !chosen_event.announce_only_on_radio && chosen_event.descr != "":
		_tooltip_GUI.open(chosen_event.descr)


func _execute_consequences(p_cons: Dictionary) -> void:
	for key : String in p_cons.keys():
		var params : Variant = p_cons[key]
		Callable(_consequences, key).call(params)
