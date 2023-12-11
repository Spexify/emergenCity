extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

func clickedTileHasCollision(clickPos : Vector2) -> bool:
	const DEFAULT_COLL_LAYER : int = 0
	var mapCoord : Vector2i = local_to_map(clickPos)
	var tileData = get_cell_tile_data(DEFAULT_COLL_LAYER, mapCoord)
	if tileData.get_collision_polygons_count(DEFAULT_COLL_LAYER) > 0:
		return true
	else:
		return false
