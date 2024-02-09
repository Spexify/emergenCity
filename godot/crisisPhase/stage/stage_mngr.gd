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
	TOOLTIPS_PNG = 6,
	INTERACTABLE_FURNITURE = 7,
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
	return _curr_stage


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
	
	#Upgrades & Optional Events: Dynamically placed furniture
	match get_curr_stage_name():
		STAGENAME_HOME:
			_create_upgrade_furniture(EMC_OverworldStatesMngr.Furniture.RAINWATER_BARREL, Vector2i(1, 15))
			_create_upgrade_furniture(EMC_OverworldStatesMngr.Furniture.ELECTRIC_RADIO, Vector2i(1, 9))
		STAGENAME_MARKET:
			#TODO: Insert if-statement, so only when THW-event is active, the THW truck is addaed:
			_place_furniture_on_position(Vector2i(6, 0), Vector2i(10, 5), 3, 1, true)
			_place_furniture_on_position(Vector2i(6, 1), Vector2i(10, 5), 3, 1, true)
			_place_furniture_on_position(Vector2i(6, 2), Vector2i(10, 5), 3, 4, true)
	
	#Hide Tooltip-Layer while game is playing
	const INVISIBLE := Color(0, 0, 0, 0)
	_curr_stage.set_layer_modulate(Layers.TOOLTIPS, INVISIBLE)


## Setup NPC position and (de)activate them
func respawn_NPCs(p_NPC_spawn_pos: Dictionary) -> void:
	#Hide all NPCs first
	for NPC: EMC_NPC in $NPCs.get_children():
		NPC.deactivate()
	
	#Dependend on the stage show and spawn NPCs
	for NPC_name: String in p_NPC_spawn_pos:
		var NPC := $NPCs.get_node(NPC_name)
		if NPC == null:
			printerr("StageMngr.update_NPCs(): Unknown NPC Name!")
			continue
		
		NPC.activate()
		NPC.position = p_NPC_spawn_pos[NPC_name]


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


func get_city_map() -> EMC_CityMap:
	return _city_map

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
		var middleground_tile: TileData = _curr_stage.get_cell_tile_data(Layers.MIDDLEGROUND, p_position + offset)
		if middleground_tile == null:
			_curr_stage.set_cell(EMC_StageMngr.Layers.MIDDLEGROUND, p_position + offset, \
				EMC_StageMngr.Atlases.UPGRADE_FURNITURE_PNG, atlas_base_coord + offset)


## Places a tile from the furniture-Atlas on the Middleground Layer
func _place_furniture_on_position(p_tilemap_pos: Vector2i, \
p_atlas_coord: Vector2i, p_tiles_width: int = 1, p_tiles_height: int = 1, \
p_overwrite_existing_tiles: bool = false) -> void:
	
	if p_tiles_width < 1: p_tiles_width = 1
	if p_tiles_height < 1: p_tiles_height = 1
	
	#Place new tiles
	for x_offset in range(0, p_tiles_width):
		for y_offset in range(0, p_tiles_height):
			#If necessary, check if previous tile exists and exit
			if p_overwrite_existing_tiles == false:
				var previous_tile := _curr_stage.get_cell_tile_data(Layers.MIDDLEGROUND, p_tilemap_pos)
				if previous_tile != null: continue
			
			var tilemap_pos := Vector2i(p_tilemap_pos.x + x_offset, p_tilemap_pos.y + y_offset)
			var atlas_coord := Vector2i(p_atlas_coord.x + x_offset, p_atlas_coord.y + y_offset)
			_curr_stage.set_cell(EMC_StageMngr.Layers.MIDDLEGROUND, tilemap_pos, \
				EMC_StageMngr.Atlases.FURNITURE_PNG, atlas_coord)


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
	
	var mert: EMC_NPC = _NPC_SCN.instantiate()
	mert.setup("Mert")
	mert.hide()
	mert.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(mert)
	_dialogue_pitches[mert.get_name()] = 0.9
	
	var momo: EMC_NPC = _NPC_SCN.instantiate()
	momo.setup("Momo")
	momo.hide()
	momo.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(momo)
	_dialogue_pitches[momo.get_name()] = 0.8
	
	var agathe: EMC_NPC = _NPC_SCN.instantiate()
	agathe.setup("Agathe")
	agathe.hide()
	agathe.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(agathe)
	_dialogue_pitches[agathe.get_name()] = 1.2
	
	var petro: EMC_NPC = _NPC_SCN.instantiate()
	petro.setup("Petro")
	petro.hide()
	petro.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(petro)
	_dialogue_pitches[petro.get_name()] = 0.65
	
	var irena: EMC_NPC = _NPC_SCN.instantiate()
	irena.setup("Irena")
	irena.hide()
	irena.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(irena)
	_dialogue_pitches[irena.get_name()] = 1.3
	
	var elias: EMC_NPC = _NPC_SCN.instantiate()
	elias.setup("Elias")
	elias.hide()
	elias.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(elias)
	_dialogue_pitches[elias.get_name()] = 0.75
	
	var kris: EMC_NPC = _NPC_SCN.instantiate()
	kris.setup("Kris")
	kris.hide()
	kris.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(kris)
	_dialogue_pitches[kris.get_name()] = 1.0
	
	var veronika: EMC_NPC = _NPC_SCN.instantiate()
	veronika.setup("Veronika")
	veronika.hide()
	veronika.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(veronika)
	_dialogue_pitches[veronika.get_name()] = 1.1
	
	var townhall_worker: EMC_NPC = _NPC_SCN.instantiate()
	townhall_worker.setup("TownhallWorker")
	townhall_worker.hide()
	townhall_worker.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(townhall_worker)
	_dialogue_pitches[townhall_worker.get_name()] = 0.95


## Handle Tap/Mouse-Input
## If necessary, set the [EMC_Avatar]s navigation target
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


## Returns only true, if click was on a tile, that belongs to the "inner" tiles 
## The outer half-tile broad "frame" doesn't count
func _is_tile_out_of_bounds(p_tile_coord: Vector2i) -> bool:
	if p_tile_coord.x <= TILE_MIN_X_COORD || p_tile_coord.x >= TILE_MAX_X_COORD:
		return true
	if p_tile_coord.y <= TILE_MIN_Y_COORD || p_tile_coord.x >= TILE_MAX_Y_COORD:
		return true
	
	return false


## TODO
func _has_tile_collision(p_tile_coord: Vector2i) -> bool:
	const PHYSICS_LAYER: int = 0
	if (p_tile_coord.x < 0 || p_tile_coord.y < 0):
		push_error("Angeklickte Tile-Koordinaten ungültig")
		return true
	
	#Back to forth, as this should be the shortest check in most cases:
	var collision_layers := [Layers.BACKGROUND, Layers.MIDDLEGROUND, Layers.TOOLTIPS]
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
	#Check first, if a tooltip tile is placed there
	tiledata = _curr_stage.get_cell_tile_data(Layers.TOOLTIPS, tile_coord)
	if tiledata != null: return tiledata
	#Next: Check the Foreground
	tiledata = _curr_stage.get_cell_tile_data(Layers.FOREGROUND, tile_coord)
	if tiledata != null: return tiledata
	#Next: Check the Middleground, which contains FURNITURE
	tiledata = _curr_stage.get_cell_tile_data(Layers.MIDDLEGROUND, tile_coord)
	if tiledata != null: return tiledata
	#Otherwise return the background tile data
	tiledata = _curr_stage.get_cell_tile_data(Layers.BACKGROUND, tile_coord)
	assert(tiledata != null, "Clicked Coordinate has no tile! Foreground Tiles don't suffice!")
	return tiledata


## TODO
func _determine_adjacent_free_tile(p_click_pos: Vector2) -> Vector2:
	var tile_coord := _get_tile_coord(p_click_pos)
	
	if !_has_tile_collision(tile_coord + Vector2i(0, 0)):
		return to_global(_curr_stage.map_to_local(tile_coord))
		
	if tile_coord.y < TILE_MAX_Y_COORD:
		var south_tile := tile_coord + Vector2i(0, 1)
		if !_has_tile_collision(south_tile):
			return to_global(_curr_stage.map_to_local(south_tile))
			
		if tile_coord.x < TILE_MAX_X_COORD:
			var southeast_tile := tile_coord + Vector2i(1, 1)
			if !_has_tile_collision(southeast_tile):
				return to_global(_curr_stage.map_to_local(southeast_tile))
				
		if tile_coord.x > TILE_MIN_X_COORD:
			var southwest_tile := tile_coord + Vector2i(-1, 1)
			if !_has_tile_collision(southwest_tile):
				return to_global(_curr_stage.map_to_local(southwest_tile))
				
	if tile_coord.x < TILE_MAX_X_COORD:
		var east_tile := tile_coord + Vector2i(1, 0)
		if !_has_tile_collision(east_tile):
			return to_global(_curr_stage.map_to_local(east_tile))
			
	if tile_coord.x > TILE_MIN_X_COORD:
		var west_tile := tile_coord + Vector2i(-1, 0)
		if !_has_tile_collision(west_tile):
			return to_global(_curr_stage.map_to_local(west_tile))
	
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
	_curr_stage.hide() #Hide Stage so clicks don't register on tiles anymore


func _on_city_map_closed() -> void:
	_curr_stage.show()


func _on_doorbell_rang(p_stage_change_ID: EMC_Action.IDs) -> void:
	_day_mngr.on_interacted_with_furniture(p_stage_change_ID)
