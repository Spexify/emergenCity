extends Node2D
class_name EMC_StageMngr
## TODO
## TileSet = A Set of Tiles
## Tile = One tile of a Tileset
## Cell = An instanciated Tile of a Tileset on a Tilemap
## Tilemap = Many cells

### This inner class is used as a tiple aka "Plain old datastructure"
### Therefore, no methods should be defined, and direct public access to its
### members is granted.
#class LastClickedTile:
	#var last_action_ID: int
	#var last_stage_name: String

signal interacted_with_furniture(p_stage_name: String)


enum Layers{
	BACKGROUND   = 0,
	MIDDLEGROUND = 1,
	TELEPORTER   = 2,
	FOREGROUND   = 3
}

enum CustomDataLayers{
	ACTION_ID   = 0,
	STAGE_NAME = 1
}

var _avatar: EMC_Avatar
var _last_clicked_tile: TileData = null #LastClickedTile

#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Konstruktor: Interne Avatar-Referenz setzen
func setup(p_avatar: EMC_Avatar) -> void:
	_avatar = p_avatar
	_avatar.arrived.connect(_on_avatar_arrived)


func get_stage() -> TileMap:
	return $Stage


func change_stage(p_stage_name: String) -> void:
	var new_stage: TileMap = load("res://stage/" + p_stage_name + ".tscn").instantiate()
	$Stage.replace_by(new_stage)
	new_stage.name = "Stage"


#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _ready():
	#_remove_redundant_navigation()
	pass


### Because the navigation works only on the BACKGROUND layer, there can be problems, as the 
### MIDDLEGROUND can still contain objects with collision. The navigation polygon on BG tiles
### is removed if it contains collision tiles in the middleground
#func _remove_redundant_navigation():
	#for bg_cell_coord in $Stage.get_used_cells(Layers.MIDDLEGROUND):
		#if _tile_has_collision(bg_cell_coord):
			#tile_data.set_navigation_polygon(0, NavigationPolygon.new())
			#var nav_poly_res = NavigationPolygon.new()
			#bg_cell_coord
			#get_cell_tile_data(0, cell).set_navigation_polygon(0, nav_poly_res)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Handle Tap/Mouse-Input
## If necessary, set the [EMC_Avatar]s navigation target
func _unhandled_input(p_event: InputEvent) -> void:
	if ((p_event is InputEventMouseButton && p_event.pressed == true)
	or (p_event is InputEventScreenTouch)):
		_last_clicked_tile = _get_tile_data_front_to_back(p_event.position)
		if _tile_is_furniture(_last_clicked_tile):
			var adjacent_free_tile_pos: Vector2 = \
				_determine_adjacent_free_tile(p_event.position)
			_avatar.set_target(adjacent_free_tile_pos)
		elif !_tile_has_collision(_get_tile_coord(p_event.position)):
			_avatar.set_target(p_event.position)


## TODO
func _tile_has_collision(p_tile_coord: Vector2i) -> bool:
	const PHYSICS_LAYER: int = 0
	var tiledata_bg = $Stage.get_cell_tile_data(Layers.BACKGROUND, p_tile_coord)
	
	if tiledata_bg.get_collision_polygons_count(PHYSICS_LAYER) > 0:
		return true
	else:
		var tiledata_mg = $Stage.get_cell_tile_data(Layers.MIDDLEGROUND, p_tile_coord)
		if tiledata_mg != null && tiledata_mg.get_collision_polygons_count(PHYSICS_LAYER) > 0:
			return true
		else:
			return false


## TODO
func _tile_is_furniture(p_tiledata: TileData) -> bool:
	var action_ID: int = p_tiledata.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID)
	var stage_name: String = p_tiledata.get_custom_data_by_layer_id(CustomDataLayers.STAGE_NAME)
	
	return (action_ID != 0) || (stage_name != "")


## TODO
func _get_tile_coord(p_click_pos: Vector2) -> Vector2i:
	#Da die TileMap skaliert ist, muss die Klickposition angepasst werden
	var scaled_click_pos := to_local(p_click_pos)
	return $Stage.local_to_map(scaled_click_pos)


## TODO
func _get_tile_data_front_to_back(p_click_pos: Vector2) -> TileData:
	var tile_coord = _get_tile_coord(p_click_pos)
	var tiledata: TileData
	#Check first, if a teleporter tile is placed there
	tiledata = $Stage.get_cell_tile_data(Layers.TELEPORTER, tile_coord)
	if tiledata != null: return tiledata
	#Next: Is a furniture placed there?
	tiledata = $Stage.get_cell_tile_data(Layers.MIDDLEGROUND, tile_coord)
	if tiledata != null: return tiledata
	#Otherwhise return the background tile data
	tiledata = $Stage.get_cell_tile_data(Layers.BACKGROUND, tile_coord)
	assert(tiledata != null, "Clicked Coordinate has no tile! Foreground Tiles don't suffice!")
	return tiledata


## TODO
func _determine_adjacent_free_tile(p_click_pos: Vector2) -> Vector2:
	var result: Vector2
	var tile_coord := _get_tile_coord(p_click_pos)
	
	if !_tile_has_collision(tile_coord + Vector2i(0, 0)):
		return to_global($Stage.map_to_local(tile_coord))
	var south_tile = tile_coord + Vector2i(0, 1)
	if !_tile_has_collision(south_tile):
		return to_global($Stage.map_to_local(south_tile))
	var southeast_tile = tile_coord + Vector2i(1, 1)
	if !_tile_has_collision(southeast_tile):
		return to_global($Stage.map_to_local(southeast_tile))
	var southwest_tile = tile_coord + Vector2i(-1, 1)
	if !_tile_has_collision(southwest_tile):
		return to_global($Stage.map_to_local(southwest_tile))
	var east_tile = tile_coord + Vector2i(1, 0)
	if !_tile_has_collision(east_tile):
		return to_global($Stage.map_to_local(east_tile))
	var west_tile = tile_coord + Vector2i(-1, 0)
	if !_tile_has_collision(west_tile):
		return to_global($Stage.map_to_local(west_tile))
	
	push_error("The clicked furniture has no adjacent free tiles that the Avatar can navigate towards!")
	return result


func _on_avatar_arrived():
	if _last_clicked_tile != null:
		var stage_name = _last_clicked_tile.get_custom_data_by_layer_id(CustomDataLayers.STAGE_NAME)
		if _last_clicked_tile.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID) != 0:
			change_stage(stage_name)
			#interacted_with_furniture.emit(stage_name) #TODO: interacted_with_furniture mit DayMngr verknüpfen
		elif stage_name != "":
			change_stage(stage_name)
