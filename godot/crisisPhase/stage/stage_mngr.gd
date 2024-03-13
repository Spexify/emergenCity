extends Node2D
class_name EMC_StageMngr
## TODO
## TileSet = A Set of Tiles
## Tile = One tile of a Tileset
## Cell = An instanciated Tile of a Tileset on a Tilemap
## Tilemap = Many cells

signal city_map_opened
signal city_map_closed

enum Atlases{ #Tileset Atlasses
	FURNITURE_PNG = 0,
	GROUND_PNG = 1,
	WALLS_PNG = 2,
	NAVIGATION_PNG = 3,
	TELEPORTERS_PNG = 4,
	UPGRADE_FURNITURE_PNG = 5,
	TOOLTIPS_PNG = 6,
	INTERACTABLE_FURNITURE = 7,
}

enum Layers{
	NAVIGATION   = 0,
	BACKGROUND   = 1,
	MIDDLEGROUND_1 = 2,
	MIDDLEGROUND_2 = 3,
	FOREGROUND   = 4,
	TOOLTIPS     = 5,
}

enum CustomDataLayers{
	ACTION_ID  = 0,
	TOOLTIP = 1,
	BOOK = 2,
}

const _NPC_SCN: PackedScene = preload("res://crisisPhase/characters/NPC.tscn")

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

const INVALID_TILE: Vector2 = Vector2(-1, -1)
const TILE_MIN_X_COORD: int = 0
const TILE_MAX_X_COORD: int = 9
const TILE_MIN_Y_COORD: int = 0
const TILE_MAX_Y_COORD: int = 16

signal dialogue_initiated(p_NPC_name: String)

@onready var _city_map: EMC_CityMap = $CityMap
@onready var _curr_stage: TileMap = $StageOffset/CurrStage

var _crisis_phase: EMC_CrisisPhase
var _avatar: EMC_Avatar
var _day_mngr: EMC_DayMngr
var _GUI: CenterContainer
var _last_clicked_tile: TileData = null
var _last_clicked_NPC: EMC_NPC = null
var _dialogue_pitches: Dictionary
var _tooltip_GUI : EMC_TooltipGUI
var _book_GUI: EMC_BookGUI
var _initial_stage_name : String = "home"
var _initial_npc : Dictionary = {}
var _opt_event_mngr: EMC_OptionalEventMngr


########################################## PUBLIC METHODS ##########################################
## Konstruktor: Interne Avatar-Referenz setzen
func setup(p_crisis_phase: EMC_CrisisPhase, p_avatar: EMC_Avatar, p_day_mngr: EMC_DayMngr, \
p_tooltip_GUI: EMC_TooltipGUI, p_book_GUI: EMC_BookGUI, p_cs_GUI: EMC_ChangeStageGUI, \
p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_crisis_phase = p_crisis_phase
	_avatar = p_avatar
	_avatar.arrived.connect(_on_avatar_arrived)
	_day_mngr = p_day_mngr
	_tooltip_GUI = p_tooltip_GUI
	_book_GUI = p_book_GUI
	_opt_event_mngr = p_opt_event_mngr
	
	_city_map.setup(_crisis_phase, p_day_mngr, self, p_tooltip_GUI, p_cs_GUI, p_opt_event_mngr)
	_dialogue_pitches["Avatar"] = 1.0
	_setup_NPCs()
	_city_map.hide()
	
	change_stage(_initial_stage_name)
	respawn_NPCs(_initial_npc)


func get_curr_stage_name() -> String:
	var parts := get_curr_stage().get_scene_file_path().split("/")
	var filename_with_ending: String = parts[parts.size() - 1]
	return filename_with_ending.substr(0, filename_with_ending.length() - 5)


func get_curr_stage() -> TileMap:
	return _curr_stage


## Change the stage to the one specified via [param p_stage_name]
func change_stage(p_stage_name: String) -> void:
	var new_stage: TileMap = load("res://crisisPhase/stage/" + p_stage_name + ".tscn").instantiate()
	$StageOffset/CurrStage.replace_by(new_stage)
	new_stage.name = "CurrStage"
	_curr_stage = $StageOffset/CurrStage
	new_stage.y_sort_enabled = true
	_curr_stage.set_scene_file_path("res://crisisPhase/stage/" + p_stage_name + ".tscn")
	_city_map.close()
	
	#Manipulate the original Tilemap according to needs:
	_create_navigation_layer_tiles()
	
	#Dynamically placed furniture for upgrades
	if get_curr_stage_name() == STAGENAME_HOME:
		_place_upgrade_furniture()
	
	#Optional Events:
	_place_optional_event_tiles()
	
	#Hide Tooltip-Layer while game is playing
	const INVISIBLE := Color(0, 0, 0, 0)
	_curr_stage.set_layer_modulate(Layers.TOOLTIPS, INVISIBLE)


## Setup NPC position and (de)activate them
func respawn_NPCs(p_NPC_spawn_pos: Dictionary) -> void:
	#Hide all NPCs first
	deactivate_NPCs()
	
	#Dependend on the stage show and spawn NPCs
	for NPC_name: String in p_NPC_spawn_pos:
		_spawn_NPC(NPC_name, p_NPC_spawn_pos[NPC_name])
	
	#Optional Event NPCs
	for opt_event in _opt_event_mngr.get_active_events():
		if get_curr_stage_name() == opt_event.stage_name:
			var spawn_NPCs_arr := opt_event.spawn_NPCs_arr
			if spawn_NPCs_arr != null && !spawn_NPCs_arr.is_empty():
				for spawn_NPCs in spawn_NPCs_arr:
					_spawn_NPC(spawn_NPCs.NPC_name, spawn_NPCs.pos)


func _spawn_NPC(p_NPC_name: String, p_spawn_pos: Vector2) -> void:
		var NPC := $NPCs.get_node(p_NPC_name)
		if NPC == null:
			printerr("StageMngr.update_NPCs(): Unknown NPC Name: " + p_NPC_name)
			return
		
		NPC.activate()
		NPC.position = p_spawn_pos


## Returns a Dictonary cotaining every actives NPC position
func get_all_active_npcs() -> Dictionary:
	var data : Dictionary = {}
	
	for npc : EMC_NPC in $NPCs.get_children():
		if npc.visible:
			data[npc.name] = {"x" : npc.position.x, "y" : npc.position.y}
			
	return data

func get_dialogue_pitches() -> Dictionary:
	return _dialogue_pitches


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


func get_city_map() -> EMC_CityMap:
	return _city_map


func get_NPC(p_NPC_name: String) -> EMC_NPC:
	for NPC: EMC_NPC in $NPCs.get_children():
		if NPC.get_name() == p_NPC_name:
			return NPC
	
	return null

## Remove all NPCs that are currently spawned
func deactivate_NPCs() -> void:
	for NPC: EMC_NPC in $NPCs.get_children():
		NPC.deactivate()


########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	_create_navigation_layer_tiles()


## Dynamiccaly create Navigation Layer tiles where there is no collision
func _create_navigation_layer_tiles() -> void:
	const NAVI_TILE_COORD = Vector2i(0, 0)
	var tile_coords: Array[Vector2i] = _curr_stage.get_used_cells(Layers.BACKGROUND)
	
	## Pro tip to debug this: You can "Force Show" the Navigation visibility:
	#_curr_stage.navigation_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_SHOW
	
	for tile_coord: Vector2i in tile_coords:
		if !_has_tile_collision(tile_coord):
			_curr_stage.set_cell(EMC_StageMngr.Layers.NAVIGATION, tile_coord, \
				EMC_StageMngr.Atlases.NAVIGATION_PNG, NAVI_TILE_COORD)
		else:
			_curr_stage.erase_cell(Layers.NAVIGATION, tile_coord)


## TODO
## The position is the "base position" = the bottom middle tile of the 3x3 grid that Upgrades can use. 
## Look at the upgrade_furniture.png to get a better picture, here is a visual representation of it:
## ("X" marks the base position):
## O O O
## O O O
## O X O
func _create_upgrade_furniture(p_upgrade_ID: EMC_Upgrade.IDs, p_position: Vector2i) -> void:
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
	
	#Offsets for 3x3 grid
	var offsets := [Vector2(-1, -2), Vector2( 0, -2), Vector2( 1, -2),
					Vector2(-1, -1), Vector2( 0, -1), Vector2( 1, -1),
					Vector2(-1,  0), Vector2( 0,  0), Vector2( 1,  0)]
	
	#Set the tiles on the positions
	for offset: Vector2i in offsets:
		var middleground_tile: TileData = _curr_stage.get_cell_tile_data(Layers.MIDDLEGROUND_2, p_position + offset)
		if middleground_tile == null:
			_curr_stage.set_cell(EMC_StageMngr.Layers.MIDDLEGROUND_2, p_position + offset, \
				EMC_StageMngr.Atlases.UPGRADE_FURNITURE_PNG, atlas_base_coord + offset)


## Places a tile from the furniture-Atlas on the Middleground 1 Layer
func _place_furniture_on_position(p_tilemap_pos: Vector2i, \
p_atlas_coord: Vector2i, p_tiles_cols: int = 1, p_tiles_rows: int = 1, \
p_overwrite_existing_tiles: bool = false) -> void:
	
	if p_tiles_cols < 1: p_tiles_cols = 1
	if p_tiles_rows < 1: p_tiles_rows = 1
	
	#Place new tiles
	for x_offset in range(0, p_tiles_cols):
		for y_offset in range(0, p_tiles_rows):
			#If necessary, check if previous tile exists and exit
			if p_overwrite_existing_tiles == false:
				var previous_tile := _curr_stage.get_cell_tile_data(Layers.MIDDLEGROUND_1, p_tilemap_pos)
				if previous_tile != null: continue
			
			var tilemap_pos := Vector2i(p_tilemap_pos.x + x_offset, p_tilemap_pos.y + y_offset)
			var atlas_coord := Vector2i(p_atlas_coord.x + x_offset, p_atlas_coord.y + y_offset)
			_curr_stage.set_cell(EMC_StageMngr.Layers.MIDDLEGROUND_1, tilemap_pos, \
				EMC_StageMngr.Atlases.FURNITURE_PNG, atlas_coord)


### Add NPCs to the scene
## TODO: should be done by a JSON in the future!
func _setup_NPCs() -> void:
	for npc : EMC_NPC in JsonMngr.load_NPC():
		npc.hide()
		npc.clicked.connect(_on_NPC_clicked)
		$NPCs.add_child(npc)
		_dialogue_pitches[npc.get_name()] = npc._dialogue_pitch


## Handle Tap/Mouse-Input
## If necessary, set the [EMC_Avatar]s navigation target
## To see the consequences, once arrived, see func _on_avatar_arrived
func _unhandled_input(p_event: InputEvent) -> void:
	if ((p_event is InputEventMouseButton && p_event.pressed == true)
	or (p_event is InputEventScreenTouch)):
		_last_clicked_NPC = null
		var click_position: Vector2 = p_event.position - $StageOffset.position
		_last_clicked_tile = _get_tile_data_front_to_back(click_position)
		if _is_tile_out_of_bounds(_get_tile_coord(click_position)): return
		if _is_tile_furniture(_last_clicked_tile):
			var adjacent_free_tile_pos: Vector2 = \
				_determine_adjacent_free_tile(click_position)
			if adjacent_free_tile_pos != INVALID_TILE:
				_avatar.set_target(adjacent_free_tile_pos + $StageOffset.position)
		elif !_has_tile_collision(_get_tile_coord(click_position)):
			_avatar.set_target(click_position + $StageOffset.position)


## Is called when the [EMC_Avatar] stops navigation, aka arrives at some point
## See func _unhandled_input for where the navigation began
## (doesn't have to be the target position that was originally set)
func _on_avatar_arrived() -> void:
	if _last_clicked_tile == null:
		#NPC angeklickt?
		if _last_clicked_NPC != null:
			dialogue_initiated.emit(_last_clicked_NPC.get_name())
	else: #FURNITURE angeklickt?
		var action_ID: EMC_Action.IDs = _last_clicked_tile.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID)
		var tooltip: String = _last_clicked_tile.get_custom_data_by_layer_id(CustomDataLayers.TOOLTIP)
		var bookID: int = _last_clicked_tile.get_custom_data_by_layer_id(CustomDataLayers.BOOK)
		
		if _is_tile_furniture(_last_clicked_tile):
			_last_clicked_tile = null
			if tooltip != "":
				_tooltip_GUI.open(tooltip)
				return
			if bookID != 0:
				_book_GUI.open(bookID)
				return
			
			_day_mngr.on_interacted_with_furniture(action_ID)


## Returns only true, if click was on a tile, that belongs to the "inner" tiles 
## The outer half-tile broad "frame" doesn't count
func _is_tile_out_of_bounds(p_tile_coord: Vector2i) -> bool:
	if p_tile_coord.x <= TILE_MIN_X_COORD || p_tile_coord.x >= TILE_MAX_X_COORD:
		return true
	if p_tile_coord.y <= TILE_MIN_Y_COORD || p_tile_coord.y >= TILE_MAX_Y_COORD:
		return true
	
	return false


## Checks multiple distinct layers for collision polygons. If any of them contain one then true
## is returned, otherwise false is returned
func _has_tile_collision(p_tile_coord: Vector2i) -> bool:
	const PHYSICS_LAYER: int = 0
	if (p_tile_coord.x < 0 || p_tile_coord.y < 0):
		push_error("Angeklickte Tile-Koordinaten ungültig")
		return true
	
	#Back to forth, as this should be the shortest check in most cases:
	var collision_layers := [Layers.BACKGROUND, Layers.MIDDLEGROUND_1, Layers.MIDDLEGROUND_2, Layers.TOOLTIPS]
	for collision_layer: Layers in collision_layers:
		var tiledata: TileData = _curr_stage.get_cell_tile_data(collision_layer, p_tile_coord)
		if tiledata != null && tiledata.get_collision_polygons_count(PHYSICS_LAYER) > 0:
			return true
	
	return false


## Check if the clicked tile is a FURNITURE, which means a decorative tile with functionality
func _is_tile_furniture(p_tiledata: TileData) -> bool:
	if p_tiledata == null:
		return false
	var tooltip: String = p_tiledata.get_custom_data_by_layer_id(CustomDataLayers.TOOLTIP)
	if tooltip != "":
		return true
	var book_ID: int = p_tiledata.get_custom_data_by_layer_id(CustomDataLayers.BOOK)
	if book_ID != 0:
		return true
	
	var action_ID: EMC_Action.IDs = p_tiledata.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID)
	return (action_ID != EMC_Action.IDs.NO_ACTION)


## TODO
func _get_tile_coord(p_click_pos: Vector2) -> Vector2i:
	#The click position has to be scaled according to the scale of the stage
	var scaled_click_pos := to_local(p_click_pos)
	return _curr_stage.local_to_map(scaled_click_pos)


## TODO
func _get_tile_data_front_to_back(p_click_pos: Vector2) -> TileData:
	var tile_coord := _get_tile_coord(p_click_pos)
	var tiledata: TileData
	
	#Front to back:
	var layers_to_check := [Layers.TOOLTIPS, Layers.FOREGROUND, Layers.MIDDLEGROUND_2, Layers.MIDDLEGROUND_1, Layers.BACKGROUND]
	for layer: Layers in layers_to_check:
		tiledata = _curr_stage.get_cell_tile_data(layer, tile_coord)
		if tiledata != null:
			return tiledata
	
	return null


## TODO
func _determine_adjacent_free_tile(p_click_pos: Vector2) -> Vector2:
	var tile_coord := _get_tile_coord(p_click_pos)
	
	if !_has_tile_collision(tile_coord) && !_is_tile_out_of_bounds(tile_coord):
		return to_global(_curr_stage.map_to_local(tile_coord))
		
	if tile_coord.y < TILE_MAX_Y_COORD:
		var south_tile := tile_coord + Vector2i(0, 1)
		if !_has_tile_collision(south_tile) && !_is_tile_out_of_bounds(south_tile):
			return to_global(_curr_stage.map_to_local(south_tile))
			
		if tile_coord.x < TILE_MAX_X_COORD:
			var southeast_tile := tile_coord + Vector2i(1, 1)
			if !_has_tile_collision(southeast_tile) && !_is_tile_out_of_bounds(southeast_tile):
				return to_global(_curr_stage.map_to_local(southeast_tile))
				
		if tile_coord.x > TILE_MIN_X_COORD:
			var southwest_tile := tile_coord + Vector2i(-1, 1)
			if !_has_tile_collision(southwest_tile) && !_is_tile_out_of_bounds(southwest_tile):
				return to_global(_curr_stage.map_to_local(southwest_tile))
				
	if tile_coord.x < TILE_MAX_X_COORD:
		var east_tile := tile_coord + Vector2i(1, 0)
		if !_has_tile_collision(east_tile) && !_is_tile_out_of_bounds(east_tile):
			return to_global(_curr_stage.map_to_local(east_tile))
			
	if tile_coord.x > TILE_MIN_X_COORD:
		var west_tile := tile_coord + Vector2i(-1, 0)
		if !_has_tile_collision(west_tile) && !_is_tile_out_of_bounds(west_tile):
			return to_global(_curr_stage.map_to_local(west_tile))
	
	push_error("The clicked furniture has no adjacent free tiles that the Avatar can navigate towards!")
	return INVALID_TILE


func _on_NPC_clicked(p_NPC: EMC_NPC) -> void:
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
	_curr_stage.hide() #Hide Stage so clicks don't register on tiles anymore
	city_map_opened.emit()


func _on_city_map_closed() -> void:
	_curr_stage.show()
	city_map_closed.emit()


func _on_doorbell_rang(p_stage_change_ID: EMC_Action.IDs) -> void:
	_day_mngr.on_interacted_with_furniture(p_stage_change_ID)


func _place_upgrade_furniture() -> void:
	for upgrade_ID: EMC_Upgrade.IDs in EMC_Upgrade.IDs.values():
		if upgrade_ID == EMC_Upgrade.IDs.EMPTY_SLOT: continue
		
		if Global.has_upgrade(upgrade_ID):
			var spawn_pos : Vector2i = Global.get_upgrade_if_equipped(upgrade_ID).get_spawn_pos()
			_create_upgrade_furniture(upgrade_ID, spawn_pos)


func _place_optional_event_tiles() -> void:
	for opt_event in _opt_event_mngr.get_active_events():
		if get_curr_stage_name() == opt_event.stage_name:
			#Spawn Tiles
			var spawn_tiles_arr := opt_event.spawn_tiles_arr
			if spawn_tiles_arr != null && !spawn_tiles_arr.is_empty():
				for spawn_tiles in spawn_tiles_arr:
					_place_furniture_on_position(spawn_tiles.tilemap_pos, spawn_tiles.atlas_coord, \
					spawn_tiles.tiles_cols, spawn_tiles.tiles_rows, spawn_tiles.overwrite_existing_tiles)
