class_name EMC_Stage
extends Node2D

enum Layers{
	NAVIGATION   = 0,
	BACKGROUND   = 1,
	MIDDLEGROUND_1 = 2,
	MIDDLEGROUND_2 = 3,
	FOREGROUND   = 4,
	TOOLTIPS     = 5,
}

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

enum CustomDataLayers{
	ACTION_ID  = 0,
	TOOLTIP = 1,
	BOOK = 2,
}

const INVALID_TILE: Vector2 = Vector2(-1, -1)
const TILE_MIN_X_COORD: int = 0
const TILE_MAX_X_COORD: int = 9
const TILE_MIN_Y_COORD: int = 0
const TILE_MAX_Y_COORD: int = 16
const NPC_TILE_COORD: Vector2i = Vector2i(3, 0)
const NAVI_TILE_COORD = Vector2i(0, 0)

var _npcs : Control
var _opt_event_mngr : EMC_OptionalEventMngr
var _stage : TileMap = null

func setup(p_stage_name : String, p_npcs : Control, p_opt_event_mngr : EMC_OptionalEventMngr) -> void:
	set_name(p_stage_name)
	_npcs = p_npcs
	_opt_event_mngr = p_opt_event_mngr

####################Public Methods#######################

func load_stage(override_spawn : Dictionary = {}) -> void:
	_stage = load("res://crisisPhase/stage/" + name + ".tscn").instantiate()
	#_stage.y_sort_enabled = true
	add_child(_stage)
	
	_load_optional_event()
	
	if name == "home":
		_place_upgrade_furniture()
	
	_create_navigation_layer_tiles()
	
	_load_npcs(override_spawn)
	
	const INVISIBLE := Color(0, 0, 0, 0)
	_stage.set_layer_modulate(Layers.TOOLTIPS, INVISIBLE)
	
func unload_stage() -> void:
	remove_child(_stage)
	_stage.queue_free()
	
	_deactivate_NPCs()
	
func get_tile_type(p_click_pos : Vector2) -> String:
	var tile_coord := _global_to_map(p_click_pos)
	
	var tile_data : TileData
	
	var layers_to_check := [Layers.TOOLTIPS, Layers.FOREGROUND, Layers.MIDDLEGROUND_2, Layers.MIDDLEGROUND_1, Layers.BACKGROUND]
	for layer: Layers in layers_to_check:
		tile_data = _stage.get_cell_tile_data(layer, tile_coord)
		if tile_data != null:
			break
			
	var tooltip : String = tile_data.get_custom_data_by_layer_id(CustomDataLayers.TOOLTIP)
	if tooltip != "":
		return "tooltip\\" + tooltip
	
	var book_id : int = tile_data.get_custom_data_by_layer_id(CustomDataLayers.BOOK)
	if book_id != 0:
		return "book\\" + str(book_id) 
		
	var action_id : int = tile_data.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID)
	if action_id != 0:
		return "action\\" + str(action_id) 
	
	return "background"
	
func get_avatar_target(p_click_pos : Vector2) -> Vector2:
	if get_tile_type(p_click_pos) == "background":
		return p_click_pos
	
	var _target_position := _determine_adjacent_free_tile(p_click_pos)
	if _target_position != INVALID_TILE:
		return _target_position
	
	return Vector2.INF

###################Private Methods######################

#*****************Navigation************************

## Dynamiccaly create Navigation Layer tiles where there is no collision
func _create_navigation_layer_tiles() -> void:
	var tile_coords: Array[Vector2i] = _stage.get_used_cells(Layers.BACKGROUND)
	
	## Pro tip to debug this: You can "Force Show" the Navigation visibility:
	#_stage.navigation_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_SHOW
	
	for tile_coord: Vector2i in tile_coords:
		if !_has_tile_collision(tile_coord):
			_stage.set_cell(Layers.NAVIGATION, tile_coord, \
				Atlases.NAVIGATION_PNG, NAVI_TILE_COORD)
		else:
			_stage.erase_cell(Layers.NAVIGATION, tile_coord)

## Checks multiple distinct layers for collision polygons. If any of them contain one then true
## is returned, otherwise false is returned
func _has_tile_collision(p_tile_coord: Vector2i) -> bool:
	const PHYSICS_LAYER: int = 0
	if (p_tile_coord.x < 0 || p_tile_coord.y < 0):
		push_error("Angeklickte Tile-Koordinaten ungültig")
		return true
	
	#Back to forth, as this should be the shortest check in most cases:
	var collision_layers := [Layers.BACKGROUND, Layers.MIDDLEGROUND_1, Layers.MIDDLEGROUND_2, Layers.TOOLTIPS]
	
	# WARNING may need to check for null
	return collision_layers.any(func(layer : int) -> bool: 
		var tile_date := _stage.get_cell_tile_data(layer, p_tile_coord)
		return tile_date != null and tile_date.get_collision_polygons_count(PHYSICS_LAYER))

#************OPTIONAL EVENTS*****************

func _load_optional_event() -> void:
	for opt_event in _opt_event_mngr.get_active_events():
		if name == opt_event.stage_name:
			#Spawn Tiles
			var spawn_tiles_arr := opt_event.spawn_tiles_arr
			if spawn_tiles_arr != null && !spawn_tiles_arr.is_empty():
				for spawn_tiles in spawn_tiles_arr:
					_place_furniture_on_position(spawn_tiles.tilemap_pos,Layers.MIDDLEGROUND_1,
					 spawn_tiles.atlas_coord, Atlases.FURNITURE_PNG,
					spawn_tiles.tiles_cols, spawn_tiles.tiles_rows, spawn_tiles.overwrite_existing_tiles)
					
			var spawn_NPCs_arr := opt_event.spawn_NPCs_arr
			if spawn_NPCs_arr != null && !spawn_NPCs_arr.is_empty():
				for spawn_NPCs in spawn_NPCs_arr:
					_spawn_NPC(spawn_NPCs.NPC_name, spawn_NPCs.pos)
					
#********************NPCs******************

## Remove all NPCs that are currently spawned
func _deactivate_NPCs() -> void:
	for npc : EMC_NPC in _npcs.get_children():
		npc.deactivate()

func _load_npcs(override_spawn : Dictionary = {}) -> void:
	#Hide all NPCs first
	_deactivate_NPCs()
	
	#Dependend on the stage show and spawn NPCs
	if not override_spawn.is_empty():
		for NPC_name: String in override_spawn:
			_spawn_NPC(NPC_name, override_spawn[NPC_name])
		
	#var list_of_npcs : Array[EMC_NPC]
	#list_of_npcs.assign(NPCs.get_children())
	#
	#var random_list : Array[int] = []
	#for i in range(list_of_npcs.size()):
		#var indexes : Array[int] = []
		#indexes.resize(list_of_npcs[i].get_spawn_ratio(get_curr_stage_name()).fill(i))
		#random_list.append_array(indexes)
	#
	#random_list.resize(int(random_list.size()/2))
	#
	#var index : Variant = random_list.pick_random()
	#if not index == null:
		#_spawn_NPC(list_of_npcs[index].name, list_of_npcs[index].get_spawn_position(get_curr_stage_name()))
		
func _spawn_NPC(p_NPC_name: String, p_spawn_pos: Vector2) -> void:
	var NPC : EMC_NPC = _npcs.get_node(p_NPC_name)
	if NPC == null:
		printerr("StageMngr.update_NPCs(): Unknown NPC Name: " + p_NPC_name)
		return
	
	var tile_position : Vector2 = _global_to_map(p_spawn_pos)
	var center_position : Vector2 = _map_to_global(tile_position)
	
	if center_position.distance_to(p_spawn_pos) > 16:
		var direction := p_spawn_pos - center_position
		direction[direction.abs().min_axis_index()] = 0
		var norm_direction := direction.normalized()
		center_position += norm_direction * 32
		if norm_direction.abs() == Vector2.DOWN:
			center_position -= Vector2.UP*20
		_stage.erase_cell(Layers.NAVIGATION, _global_to_map(center_position + norm_direction*32))
	
	NPC.activate()
	NPC.position = center_position
	
	_stage.erase_cell(Layers.NAVIGATION, tile_position)

#*************UPGRADES*****************

func _place_upgrade_furniture() -> void:
	for upgrade: EMC_Upgrade in Global.get_equipped_upgrades():
		var spawn_pos : Vector2i = upgrade.get_spawn_pos()
		var atlas_coords : Vector2i = upgrade._atlas_coord
		_place_furniture_on_position(spawn_pos, Layers.MIDDLEGROUND_2,
		atlas_coords, Atlases.UPGRADE_FURNITURE_PNG, upgrade._cols, upgrade._rows, true)

#***************UTIL******************

## Places a tile from the furniture-Atlas on the Middleground 1 Layer
func _place_furniture_on_position(p_tilemap_pos: Vector2i, p_layer : Layers,\
p_atlas_coord: Vector2i, p_altlas : Atlases, p_tiles_cols: int = 1, p_tiles_rows: int = 1, \
p_overwrite_existing_tiles: bool = false) -> void:
	
	if p_tiles_cols < 1: p_tiles_cols = 1
	if p_tiles_rows < 1: p_tiles_rows = 1
	
	#Place new tiles
	for x_offset in range(0, p_tiles_cols):
		for y_offset in range(0, p_tiles_rows):
			#If necessary, check if previous tile exists and exit
			if p_overwrite_existing_tiles == false:
				var previous_tile := _stage.get_cell_tile_data(p_layer, p_tilemap_pos)
				if previous_tile != null: continue
			
			var tilemap_pos := Vector2i(p_tilemap_pos.x + x_offset, p_tilemap_pos.y + y_offset)
			var atlas_coord := Vector2i(p_atlas_coord.x + x_offset, p_atlas_coord.y + y_offset)
			_stage.set_cell(p_layer, tilemap_pos, p_altlas, atlas_coord)
			
func _global_to_map(p_click_pos: Vector2) -> Vector2i:
	#The click position has to be scaled according to the scale of the stage
	var scaled_click_pos := to_local(p_click_pos)
	return _stage.local_to_map(scaled_click_pos)

func _map_to_global(p_click_pos: Vector2) -> Vector2i:
	#The click position has to be scaled according to the scale of the stage
	var scaled_click_pos := _stage.map_to_local(p_click_pos)
	return to_global(scaled_click_pos)
	
## Returns only true, if click was on a tile, that belongs to the "inner" tiles 
## The outer half-tile broad "frame" doesn't count
func _is_tile_out_of_bounds(p_tile_coord: Vector2i) -> bool:
	if p_tile_coord.x <= TILE_MIN_X_COORD || p_tile_coord.x >= TILE_MAX_X_COORD:
		return true
	if p_tile_coord.y <= TILE_MIN_Y_COORD || p_tile_coord.y >= TILE_MAX_Y_COORD:
		return true
	
	return false

func _determine_adjacent_free_tile(p_click_pos: Vector2) -> Vector2:
	var tile_coord := _global_to_map(p_click_pos)
	
	if !_has_tile_collision(tile_coord) && !_is_tile_out_of_bounds(tile_coord):
		return p_click_pos
		
	if tile_coord.y < TILE_MAX_Y_COORD:
		var south_tile := tile_coord + Vector2i(0, 1)
		if !_has_tile_collision(south_tile) && !_is_tile_out_of_bounds(south_tile):
			return _map_to_global(south_tile)
			
		if tile_coord.x < TILE_MAX_X_COORD:
			var southeast_tile := tile_coord + Vector2i(1, 1)
			if !_has_tile_collision(southeast_tile) && !_is_tile_out_of_bounds(southeast_tile):
				return _map_to_global(southeast_tile)
				
		if tile_coord.x > TILE_MIN_X_COORD:
			var southwest_tile := tile_coord + Vector2i(-1, 1)
			if !_has_tile_collision(southwest_tile) && !_is_tile_out_of_bounds(southwest_tile):
				return _map_to_global(southwest_tile)
				
	if tile_coord.x < TILE_MAX_X_COORD:
		var east_tile := tile_coord + Vector2i(1, 0)
		if !_has_tile_collision(east_tile) && !_is_tile_out_of_bounds(east_tile):
			return _map_to_global(east_tile)
			
	if tile_coord.x > TILE_MIN_X_COORD:
		var west_tile := tile_coord + Vector2i(-1, 0)
		if !_has_tile_collision(west_tile) && !_is_tile_out_of_bounds(west_tile):
			return _map_to_global(west_tile)
	
	push_error("The clicked furniture has no adjacent free tiles that the Avatar can navigate towards!")
	return INVALID_TILE
