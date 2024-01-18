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
	TELEPORTERS_PNG = 4
}

enum Layers{
	NAVIGATION   = 0,
	BACKGROUND   = 1,
	MIDDLEGROUND = 2,
	TELEPORTER   = 3,
	FOREGROUND   = 4,
}

enum CustomDataLayers{
	ACTION_ID  = 0,
	STAGE_NAME = 1
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

var _avatar: EMC_Avatar
var _day_mngr: EMC_DayMngr
var _GUI: CenterContainer
var _city_map: EMC_CityMap
var _last_clicked_tile: TileData = null
var _last_clicked_NPC: EMC_NPC = null


#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Konstruktor: Interne Avatar-Referenz setzen
func setup(p_avatar: EMC_Avatar, p_day_mngr: EMC_DayMngr, p_tooltip_GUI: EMC_TooltipGUI, \
	p_cs_GUI: EMC_ChangeStageGUI) -> void:
	_avatar = p_avatar
	_avatar.arrived.connect(_on_avatar_arrived)
	_day_mngr = p_day_mngr
	_city_map = $CityMap
	$CityMap.setup(p_day_mngr, self, p_tooltip_GUI, p_cs_GUI)
	$CityMap.hide()
	_setup_NPCs()


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
	_city_map.close()


#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _ready() -> void:
	_create_navigation_layer_tiles()


### Because the navigation works only on the BACKGROUND layer, there can be problems, as the 
### MIDDLEGROUND can still contain objects with collision. The navigation polygon on BG tiles
### is removed if it contains collision tiles in the middleground
#func _remove_redundant_navigation():
	#for bg_cell_coord in $CurrStage.get_used_cells(Layers.MIDDLEGROUND):
		#if _tile_has_collision(bg_cell_coord):
			#tile_data.set_navigation_polygon(0, NavigationPolygon.new())
			#var nav_poly_res = NavigationPolygon.new()
			#bg_cell_coord
			#get_cell_tile_data(0, cell).set_navigation_polygon(0, nav_poly_res)
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


### Add NPCs to the scene
## TODO: should be done by a JSON in the future!
func _setup_NPCs() -> void:
	var gerhard: EMC_NPC = _NPC_SCN.instantiate()
	gerhard.setup("Gerhard")
	gerhard.hide()
	gerhard.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(gerhard)
	
	var friedel: EMC_NPC = _NPC_SCN.instantiate()
	friedel.setup("Friedel")
	friedel.hide()
	friedel.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(friedel)
	
	var julia: EMC_NPC = _NPC_SCN.instantiate()
	julia.setup("Julia")
	julia.hide()
	julia.clicked.connect(_on_NPC_clicked)
	$NPCs.add_child(julia)


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


## TODO
func _is_tile_furniture(p_tiledata: TileData) -> bool:
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
	#Check first, if a teleporter tile is placed there
	tiledata = $CurrStage.get_cell_tile_data(Layers.TELEPORTER, tile_coord)
	if tiledata != null: return tiledata
	#Next: Is a furniture placed there?
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
		if _is_tile_furniture(_last_clicked_tile):
			_last_clicked_tile = null
			if action_ID == EMC_Action.IDs.CITY_MAP:
				_city_map.open()
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
