extends Node2D
class_name EMC_StageMngr
## TODO
## TileSet = A Set of Tiles
## Tile = One tile of a Tileset
## Cell = An instanciated Tile of a Tileset on a Tilemap
## Tilemap = Many cells


enum Atlases{ #Tileset Atlasses
	FURNITURE_PNG = 0,
	GROUND_PNG = 1,
	WALLS_PNG = 2,
	NAVIGATION_PNG = 3,
	TELEPORTERS_PNG = 4,
	UPGRADE_FURNITURE_PNG = 5,
}

enum Layers{
	NAVIGATION   = 0,
	BACKGROUND   = 1,
	MIDDLEGROUND = 2,
	FOREGROUND   = 3,
	TOOLTIPS     = 4,
}

enum CustomDataLayers{
	ACTION_ID  = 0,
	TOOLTIP = 1
}

const _NPC_SCN: PackedScene = preload("res://crisisPhase/characters/NPC.tscn")

const STAGENAME_HOME: String = "home"
const STAGENAME_MARKET: String = "market"

const INVALID_TILE: Vector2 = Vector2(-1, -1)
const TILE_MIN_X_COORD: int = 0
const TILE_MAX_X_COORD: int = 8
const TILE_MIN_Y_COORD: int = 0
const TILE_MAX_Y_COORD: int = 15

signal dialogue_initiated(p_NPC_name: String)

@onready var _city_map: EMC_CityMap = $CityMap

var _crisis_phase: EMC_CrisisPhase
var _avatar: EMC_Avatar
var _day_mngr: EMC_DayMngr
var _GUI: CenterContainer
var _last_clicked_tile: TileData = null
var _last_clicked_NPC: EMC_NPC = null
var _dialogue_pitches: Dictionary
var _tooltip_GUI : EMC_TooltipGUI
var _initial_stage_name : String = "home"


########################################## PUBLIC METHODS ##########################################
## Konstruktor: Interne Avatar-Referenz setzen
func setup(p_crisis_phase: EMC_CrisisPhase, p_avatar: EMC_Avatar, p_day_mngr: EMC_DayMngr, p_tooltip_GUI: EMC_TooltipGUI, \
	p_cs_GUI: EMC_ChangeStageGUI) -> void:
	_crisis_phase = p_crisis_phase
	_avatar = p_avatar
	_avatar.arrived.connect(_on_avatar_arrived)
	_day_mngr = p_day_mngr
	_tooltip_GUI = p_tooltip_GUI
	
	_city_map.setup(_crisis_phase, p_day_mngr, self, p_tooltip_GUI, p_cs_GUI)
	_dialogue_pitches["Avatar"] = 1.0
	_setup_NPCs()
	_city_map.hide()
	
	change_stage(_initial_stage_name)


func get_curr_stage_name() -> String:
	var parts := get_curr_stage().get_scene_file_path().split("/")
	var filename_with_ending: String = parts[parts.size() - 1]
	return filename_with_ending.substr(0, filename_with_ending.length() - 5)


func get_curr_stage() -> TileMap:
	return $CurrStage


func change_stage(p_stage_name: String) -> void:
	var new_stage: TileMap = load("res://crisisPhase/stage/" + p_stage_name + ".tscn").instantiate()
	$CurrStage.replace_by(new_stage)
	new_stage.name = "CurrStage"
	new_stage.y_sort_enabled = true
	$CurrStage.set_scene_file_path("res://crisisPhase/stage/" + p_stage_name + ".tscn")
	_update_NPCs()
	_create_navigation_layer_tiles()
	if get_curr_stage_name() == STAGENAME_HOME:
		_create_upgrade_furniture(EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL, Vector2i(6, 3))
		_create_upgrade_furniture(EMC_OverworldStatesMngr.Furniture.ELECTRIC_RADIO, Vector2i(2, 2))
	_city_map.close()
	#Hide Tooltip-Layer while game is playing
	const INVISIBLE := Color(0, 0, 0, 0)
	$CurrStage.set_layer_modulate(Layers.TOOLTIPS, INVISIBLE)


func get_dialogue_pitches() -> Dictionary:
	return _dialogue_pitches


func save() -> Dictionary:
	var data : Dictionary = {
		"node_path" : get_path(),
		"stage_name" : get_curr_stage_name(),
	}
	return data



func load_state(data : Dictionary) -> void:
	_initial_stage_name = data.get("stage_name", "home")


########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	_create_navigation_layer_tiles()


## Dynamiccaly create Navigation Layer tiles where there is no collision
func _create_navigation_layer_tiles() -> void:
	const NAVI_TILE_COORD = Vector2i(0, 0)
	var tile_coords: Array[Vector2i] = $CurrStage.get_used_cells(Layers.BACKGROUND)
	
	## Pro tip to debug this: You can "Force Show" the Navigation visibility:
	#$CurrStage.navigation_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_SHOW
	
	for tile_coord: Vector2i in tile_coords:
		if !_has_tile_collision(tile_coord):
			$CurrStage.set_cell(EMC_StageMngr.Layers.NAVIGATION, tile_coord, \
				EMC_StageMngr.Atlases.NAVIGATION_PNG, NAVI_TILE_COORD)
		else:
			$CurrStage.erase_cell(Layers.NAVIGATION, tile_coord)


## TODO
## The position is the "base position" = the bottom middle tile of the 3x3 grid that Upgrades can use. 
## Look at the upgrade_furniture.png to get a better picture, here is a visual representation of it:
## ("X" marks the base position):
## O O O
## O O O
## O X O
func _create_upgrade_furniture(p_upgrade_ID: EMC_OverworldStatesMngr.Furniture, p_position: Vector2i) -> void:
	#Determine base position of upgrade_furniture.png:
	const ATLAS_UPGRADE_WIDTH = 3 #How many tiles one upgrade takes up in the x-dimension
	const ATLAS_UPGRADE_HEIGHT = 3 #How many tiles one upgrade takes up in the y-dimension
	const ATLAS_UPGRADE_COLUMNS = 4 #How many 3x3-tiles of upgrades fit horizontally in the .png
	const BASE_X_COORD_OFFSET = 1
	const BASE_Y_COORD_OFFSET = 2
	
	var atlas_base_x_coord: int = (p_upgrade_ID * ATLAS_UPGRADE_WIDTH + BASE_X_COORD_OFFSET) % \
		(ATLAS_UPGRADE_COLUMNS * ATLAS_UPGRADE_WIDTH)
	var atlas_base_y_coord: int = floor(p_upgrade_ID/float(ATLAS_UPGRADE_COLUMNS)) * ATLAS_UPGRADE_HEIGHT + \
		BASE_Y_COORD_OFFSET
	var atlas_base_coord: Vector2i = Vector2i(atlas_base_x_coord, atlas_base_y_coord);
	print("Upgrade Base coord:" + str(atlas_base_coord))
	
	#Offsets for 3x3 grid
	var offsets := [Vector2(-1, -2), Vector2( 0, -2), Vector2( 1, -2),
					Vector2(-1, -1), Vector2( 0, -1), Vector2( 1, -1),
					Vector2(-1,  0), Vector2( 0,  0), Vector2( 1,  0)]
	
	#Set the tiles on the positions
	for offset: Vector2i in offsets:
		$CurrStage.set_cell(EMC_StageMngr.Layers.MIDDLEGROUND, p_position + offset, \
			EMC_StageMngr.Atlases.UPGRADE_FURNITURE_PNG, atlas_base_coord + offset)


### Add NPCs to the scene
## TODO: should be done by a JSON in the future!
func _setup_NPCs() -> void:
	var gerhard: EMC_NPC = _NPC_SCN.instantiate()
	gerhard.setup("Gerhard")
	gerhard.hide()
	gerhard.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(gerhard)
	_dialogue_pitches[gerhard.get_name()] = 0.5
	
	var friedel: EMC_NPC = _NPC_SCN.instantiate()
	friedel.setup("Friedel")
	friedel.hide()
	friedel.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(friedel)
	_dialogue_pitches[friedel.get_name()] = 0.6
	
	var julia: EMC_NPC = _NPC_SCN.instantiate()
	julia.setup("Julia")
	julia.hide()
	julia.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(julia)
	_dialogue_pitches[julia.get_name()] = 1.3


## Setup NPC position and (de)activate them
func _update_NPCs() -> void:
	#Hide all NPCs first
	for NPC: EMC_NPC in $NPCs.get_children():
		NPC.deactivate()
	
	#Dependend on the stage show and reposition NPCs
	match get_curr_stage_name():
		"home":
			pass
		"market":
			var gerhard := $NPCs.get_node("Gerhard") #Magic String, WIP
			gerhard.activate()
			gerhard.position = Vector2(200, 700) #Spawn position of stages in JSON in the future!
			var friedel := $NPCs.get_node("Friedel") #Magic String, WIP
			friedel.activate()
			friedel.position = Vector2(260, 700) #Spawn position of stages in JSON in the future!
			var julia := $NPCs.get_node("Julia") #Magic String, WIP
			julia.activate()
			julia.position = Vector2(280, 350) #Spawn position of stages in JSON in the future!
		_:
			printerr("StageMngr._update_NPCs(): Unknown Stage Name!")
	pass


## Handle Tap/Mouse-Input
## If necessary, set the [EMC_Avatar]s navigation target
func _unhandled_input(p_event: InputEvent) -> void:
	if ((p_event is InputEventMouseButton && p_event.pressed == true)
	or (p_event is InputEventScreenTouch)):
		_last_clicked_NPC = null
		_last_clicked_tile = _get_tile_data_front_to_back(p_event.position)
		if _is_tile_furniture(_last_clicked_tile):
			var adjacent_free_tile_pos: Vector2 = \
				_determine_adjacent_free_tile(p_event.position)
			if adjacent_free_tile_pos != INVALID_TILE:
				_avatar.set_target(adjacent_free_tile_pos)
		elif !_has_tile_collision(_get_tile_coord(p_event.position)):
			_avatar.set_target(p_event.position)


## TODO
func _has_tile_collision(p_tile_coord: Vector2i) -> bool:
	const PHYSICS_LAYER: int = 0
	if (p_tile_coord.x < 0 || p_tile_coord.y < 0):
		push_error("Angeklickte Tile-Koordinaten ungültig")
		return true
	var tiledata_bg: TileData = $CurrStage.get_cell_tile_data(Layers.BACKGROUND, p_tile_coord)
	
	if tiledata_bg.get_collision_polygons_count(PHYSICS_LAYER) > 0:
		return true
	else:
		var tiledata_mg: TileData = $CurrStage.get_cell_tile_data(Layers.MIDDLEGROUND, p_tile_coord)
		if tiledata_mg != null && tiledata_mg.get_collision_polygons_count(PHYSICS_LAYER) > 0:
			return true
		else:
			return false


## Check if the clicked tile is a FURNITURE, which means a decorative tile with functionality
func _is_tile_furniture(p_tiledata: TileData) -> bool:
	var tooltip: String = p_tiledata.get_custom_data_by_layer_id(CustomDataLayers.TOOLTIP)
	if tooltip != "":
		return true
	
	var action_ID: EMC_Action.IDs = p_tiledata.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID)
	return (action_ID != EMC_Action.IDs.NO_ACTION)


## TODO
func _get_tile_coord(p_click_pos: Vector2) -> Vector2i:
	#The click position has to be scaled according to the scale of the stage
	var scaled_click_pos := to_local(p_click_pos)
	return $CurrStage.local_to_map(scaled_click_pos)


## TODO
func _get_tile_data_front_to_back(p_click_pos: Vector2) -> TileData:
	var tile_coord := _get_tile_coord(p_click_pos)
	var tiledata: TileData
	#Check first, if a tooltip tile is placed there
	tiledata = $CurrStage.get_cell_tile_data(Layers.TOOLTIPS, tile_coord)
	if tiledata != null: return tiledata
	#Next: Check the Foreground
	tiledata = $CurrStage.get_cell_tile_data(Layers.FOREGROUND, tile_coord)
	if tiledata != null: return tiledata
	#Next: Check the Middleground, which contains FURNITURE
	tiledata = $CurrStage.get_cell_tile_data(Layers.MIDDLEGROUND, tile_coord)
	if tiledata != null: return tiledata
	#Otherwise return the background tile data
	tiledata = $CurrStage.get_cell_tile_data(Layers.BACKGROUND, tile_coord)
	assert(tiledata != null, "Clicked Coordinate has no tile! Foreground Tiles don't suffice!")
	return tiledata


## TODO
func _determine_adjacent_free_tile(p_click_pos: Vector2) -> Vector2:
	var tile_coord := _get_tile_coord(p_click_pos)
	
	if !_has_tile_collision(tile_coord + Vector2i(0, 0)):
		return to_global($CurrStage.map_to_local(tile_coord))
		
	if tile_coord.y < TILE_MAX_Y_COORD:
		var south_tile := tile_coord + Vector2i(0, 1)
		if !_has_tile_collision(south_tile):
			return to_global($CurrStage.map_to_local(south_tile))
			
		if tile_coord.x < TILE_MAX_X_COORD:
			var southeast_tile := tile_coord + Vector2i(1, 1)
			if !_has_tile_collision(southeast_tile):
				return to_global($CurrStage.map_to_local(southeast_tile))
				
		if tile_coord.x > TILE_MIN_X_COORD:
			var southwest_tile := tile_coord + Vector2i(-1, 1)
			if !_has_tile_collision(southwest_tile):
				return to_global($CurrStage.map_to_local(southwest_tile))
				
	if tile_coord.x < TILE_MAX_X_COORD:
		var east_tile := tile_coord + Vector2i(1, 0)
		if !_has_tile_collision(east_tile):
			return to_global($CurrStage.map_to_local(east_tile))
			
	if tile_coord.x > TILE_MIN_X_COORD:
		var west_tile := tile_coord + Vector2i(-1, 0)
		if !_has_tile_collision(west_tile):
			return to_global($CurrStage.map_to_local(west_tile))
	
	push_error("The clicked furniture has no adjacent free tiles that the Avatar can navigate towards!")
	return INVALID_TILE


## Is called when the [EMC_Avatar] stops navigation, aka arrives at some point
## (doesn't have to be the target position that was originally set)
func _on_avatar_arrived() -> void:
	if _last_clicked_tile == null:
		#NPC angeklickt?
		if _last_clicked_NPC != null:
			dialogue_initiated.emit(_last_clicked_NPC.get_name())
	else: #FURNITURE angeklickt?
		var action_ID: EMC_Action.IDs = _last_clicked_tile.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID)
		var tooltip: String = _last_clicked_tile.get_custom_data_by_layer_id(CustomDataLayers.TOOLTIP)
		
		if _is_tile_furniture(_last_clicked_tile):
			_last_clicked_tile = null
			if tooltip != "":
				_tooltip_GUI.open(tooltip)
				return
			
			if action_ID == EMC_Action.IDs.CITY_MAP:
				if OverworldStatesMngr.get_isolation_state() != OverworldStatesMngr.IsolationState.ISOLATION:	
					_city_map.open()
				else: 
					_tooltip_GUI.open("Die City Map ist nicht betretbar!")
			else:
				_day_mngr.on_interacted_with_furniture(action_ID)


func _on_NPC_clicked(p_NPC: EMC_NPC) -> void:
	#print("NPC " + p_NPC.get_name() + " was clicked")
	_last_clicked_tile = null
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


func _on_city_map_opened() -> void:
	$CurrStage.hide() #Hide Stage so clicks don't register on tiles anymore


func _on_city_map_closed() -> void:
	$CurrStage.show()


func _on_doorbell_rang(p_stage_change_ID: EMC_Action.IDs) -> void:
	_day_mngr.on_interacted_with_furniture(p_stage_change_ID)
