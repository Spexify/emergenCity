@tool
extends Node2D
class_name EMC_StageMngr
## TODO
## TileSet = A Set of Tiles
## Tile = One tile of a Tileset
## Cell = An instanciated Tile of a Tileset on a Tilemap
## Tilemap = Many cells

#signal city_map_opened
#signal city_map_closed

const STAGENAME_HOME: String = "home"
#Public Locations:
const STAGENAME_MARKET: String = "market"
const STAGENAME_TOWNHALL: String = "townhall"
const STAGENAME_PARK: String = "park"
#Private Locations:
const STAGENAME_GARDENHOUSE: String = "gardenhouse"
const STAGENAME_ROWHOUSE: String = "rowhouse"
const STAGENAME_MANSION: String = "mansion"
const STAGENAME_PENTHOUSE: String = "penthouse"
#kann mehrfach verwendet werden in der Zukunft:
const STAGENAME_APARTMENT_DEFAULT: String = "apartment_default" 
const STAGENAME_APARTMENT_MERT: String = "apartment_mert"
const STAGENAME_APARTMENT_CAMPER: String = "apartment_camper"

const _STAGE_SCN = preload("res://crisisPhase/stage/stage.tscn")

signal npc_interaction(npc: EMC_NPC)
signal stage_changed(stage_name: String)
signal npc_act

@onready var _curr_stage: EMC_Stage 
@onready var NPCs : Control = $NPCs

@export var editor_stage: String = "home"

### Stages

var _avatar: EMC_Avatar
var _day_mngr: EMC_DayMngr
var _last_click_position: Vector2 = Vector2.INF
var _last_clicked_NPC: EMC_NPC = null

var _gui_mngr : EMC_GUIMngr

var _initial_stage_name : String = "home"
var _initial_npc : Dictionary = {}
var _opt_event_mngr: EMC_OptionalEventMngr


########################################## PUBLIC METHODS ##########################################
## Konstruktor: Interne Avatar-Referenz setzen
func setup(p_avatar: EMC_Avatar, p_day_mngr: EMC_DayMngr, \
p_gui_mngr : EMC_GUIMngr, p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_avatar = p_avatar
	_avatar.arrived.connect(_on_avatar_arrived)
	_day_mngr = p_day_mngr
	_opt_event_mngr = p_opt_event_mngr
	
	_gui_mngr = p_gui_mngr
	
	_setup_stages()

	_setup_NPCs()
	
	change_stage(_initial_stage_name, _initial_npc, false)
	
	OverworldStatesMngr.change.connect(state_changed)

## Change the stage to the one specified via [param p_stage_name]
## Wait: waits for the day transition to change_stage,
## if the stage change does not advance the day it should be set to false
func change_stage(p_stage_name: String, override_spawn : Dictionary = {}, wait : bool = true) -> void:
	#print("Want to change stage to: " + p_stage_name)
	if wait:
		await _day_mngr.period_increased
	if _curr_stage != null:
		_curr_stage.unload_stage()
	_curr_stage = $StageOffset.get_node(p_stage_name)
	_curr_stage.load_stage(override_spawn)
	_curr_stage.show_electricity()
	#print("Change stage to: " + p_stage_name)
	
	stage_changed.emit(get_curr_stage_name())

func get_curr_stage_name() -> String:
	return _curr_stage.name

func get_curr_stage() -> TileMap:
	return _curr_stage._stage

func get_stage() -> EMC_Stage:
	return _curr_stage

## Returns a Dictonary cotaining every actives NPC position
func get_all_active_npcs() -> Dictionary:
	var data : Dictionary = {}
	
	for npc : EMC_NPC in NPCs.get_children():
		if npc.visible:
			data[npc.name] = {"x" : npc.position.x, "y" : npc.position.y}
			
	return data

func save() -> Dictionary:
	var data : Dictionary = {
		"node_path" : get_path(),
		"stage_name" : get_curr_stage_name(),
		"npc_pos" : get_all_active_npcs(), 
	}
	return data

func load_state(data : Dictionary) -> void:
	_initial_stage_name = data.get("stage_name", "home")
	_initial_npc = data.get("npc_pos", {})
	for npc : String in _initial_npc:
		_initial_npc[npc] = Vector2(_initial_npc[npc].get("x", 0), _initial_npc[npc].get("y", 0))

func get_NPC(p_NPC_name: String) -> EMC_NPC:
	return NPCs.get_node(p_NPC_name.to_pascal_case())

## Remove all NPCs that are currently spawned
func deactivate_NPCs() -> void:
	for NPC: EMC_NPC in NPCs.get_children():
		NPC.hide()

func let_npcs_act() -> void:
	var npcs := NPCs.get_children()
	npcs.shuffle()
	for npc : EMC_NPC in npcs:
		var brain : EMC_NPC_Brain = npc.get_comp(EMC_NPC_Brain)
		if brain:
			brain.act()
			
	#get_NPC("Gerhard").get_comp(EMC_NPC_Brain).act()
	#get_NPC("Friedel").get_comp(EMC_NPC_Brain).act()
	
	#npc_act.emit()

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	if Engine.is_editor_hint():
		_curr_stage = $StageOffset.get_children()[0]
		_curr_stage.setup(editor_stage, NPCs, _opt_event_mngr)
		_curr_stage.load_stage()

func state_changed(state : String) -> void:
	if state.get_basename() == "ElectricityState":
		_curr_stage.show_electricity()

func _setup_stages() -> void:
	var stage_names := ["market", "townhall", "park", "gardenhouse", "rowhouse",
	"mansion", "penthouse", "apartment_default", "apartment_mert", "apartment_camper"]
	
	$StageOffset.get_children()[0].setup("home", NPCs, _opt_event_mngr)
	
	for stage_name : String in stage_names:
		var stage := _STAGE_SCN.instantiate()
		$StageOffset.add_child(stage)
		stage.setup(stage_name, NPCs, _opt_event_mngr)
	
### Add NPCs to the scene
func _setup_NPCs() -> void:
	var dict: Dictionary = JsonMngr.load_NPC()
	for npc : EMC_NPC in dict:
		npc.setup(_gui_mngr, self, _day_mngr)
		NPCs.add_child(npc)
		
		for comp: Variant in dict[npc]:
			npc.add_child(comp)
		
		npc.hide()
		npc.clicked.connect(_on_NPC_clicked)

## Handle Tap/Mouse-Input
## If necessary, set the [EMC_Avatar]s navigation target
## To see the consequences, once arrived, see func _on_avatar_arrived
func _unhandled_input(p_event: InputEvent) -> void:
	if ((p_event is InputEventMouseButton && p_event.pressed == true)
	or (p_event is InputEventScreenTouch)):
		_last_clicked_NPC = null
		var click_position: Vector2 = p_event.position
		_last_click_position = click_position
		if not _curr_stage.get_viewport_rect().has_point(p_event.position): return
		
		var _target_pos := _curr_stage.get_avatar_target(click_position)
		if _target_pos.is_finite():
			_avatar.set_target(_target_pos)

func _on_NPC_clicked(p_NPC: EMC_NPC) -> void:
	_last_click_position = Vector2.INF
	_last_clicked_NPC = p_NPC
	var offset: Vector2 = Vector2.ZERO
	if _avatar.position[0] < p_NPC.position[0]: #X Pos Offset
		offset += Vector2(-50, 0)
	else:
		offset += Vector2(50, 0)
	if _avatar.position[1] < p_NPC.position[1]: #> Pos Offset
		offset += Vector2(0, -50)
	else:
		offset += Vector2(0, 50)
		
	_avatar.set_target(p_NPC.position + offset)

## Is called when the [EMC_Avatar] stops navigation, aka arrives at some point
## See func _unhandled_input for where the navigation began
## (doesn't have to be the target position that was originally set)
func _on_avatar_arrived() -> void:
	if not _last_click_position.is_finite() and _last_clicked_NPC != null:
		#NPC
			npc_interaction.emit(_last_clicked_NPC)
	else: 
		#FURNITURE
		var raw_type_content : PackedStringArray = _curr_stage.get_tile_type(_last_click_position).split("\\")
		var type : String = raw_type_content[0]
		var content : String
		if raw_type_content.size() >= 2:
			content = raw_type_content[1]
		match type:
			"tooltip":
				_gui_mngr.request_gui("TooltipGUI", [content])
			"book":
				_gui_mngr.request_gui("BookGUI", [content.to_int()])
			"action":
				_day_mngr.on_interacted_with_furniture(content.to_int())


func _on_doorbell_rang(p_stage_change_ID: int) -> void:
	_day_mngr.on_interacted_with_furniture(p_stage_change_ID)
