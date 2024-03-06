extends Node
class_name EMC_Upgrade

signal was_pressed(p_upgrade : EMC_Upgrade)

enum IDs{
	EMPTY_SLOT = 0,
	RAINWATER_BARREL = 1,
	ELECTRIC_RADIO = 2,
	CRANK_RADIO = 3,
	GAS_COOKER = 4,
	#WATER_RESERVOIR = .., #UNUSED
}

var _id : IDs
var _display_name : String
var _description : String
var _price : int
var _tilemap_position : Vector2i #theoretically one could use the _ID for the frame, but it's not objectively better
var _state : int
var _state_maximum : int
var _spawn_pos: Vector2i


func setup(p_upgrade_id: IDs) -> void:
	# TODO: JSONification
	# TODO: Write descriptions
	_id = p_upgrade_id
	
	var data : Dictionary = JsonMngr.id_to_upgrade_data(_id)
	_display_name = data.get("display_name", "")
	_description = data.get("description", "")
	_price = data.get("price", 0)
	_tilemap_position = data.get("tilemap_position", Vector2i(3,3))
	_state = data.get("state", 0)
	_state_maximum = data.get("state_maximum", 0) 
	if data.has("spawn_pos"):
		_spawn_pos = data["spawn_pos"]
	
	#match _id:
		#
		#IDs.EMPTY_SLOT:
			#_display_name = "" ; _description = "" ; _price = 0 ; _tilemap_position = Vector2i(3,3) ; _state = 0 ; _state_maximum = 0
		#
		##Upgrade_ID.WATER_RESERVOIR: _display_name = "Wasserspeicher" ; _description = "" ; _tilemap_position = Vector2i(0,0) ; _state = -1 ; _state_maximum = -1 # UNUSED
		#
		#IDs.RAINWATER_BARREL:
			#_display_name = "Regentonne" ; _description = "" ; _price = 1000 ; _tilemap_position = Vector2i(1,0) ; _state = 0 ; _state_maximum = 24 # state: the water quantity in units of 250ml
			#_spawn_pos = Vector2i(1, 15)
		#
		#IDs.ELECTRIC_RADIO:
			#_display_name = "Elektrisches Radio" ; _description = "" ; _price = 200 ; _tilemap_position = Vector2i(2,0) ; _state = 0 ; _state_maximum = 0
			#_spawn_pos = Vector2i(1, 9)
			#
		#IDs.CRANK_RADIO:
			#_display_name = "Kurbelradio" ; _description = "" ; _price = 500 ; _tilemap_position = Vector2i(3,0) ; _state = 0 ; _state_maximum = 0
			#_spawn_pos = Vector2i(1, 9)
		#
		#IDs.GAS_COOKER:
			#_display_name = "Gaskocher"
			#_description = ""
			#_price = 1000
			#_tilemap_position = Vector2i(0,1)
			#_state = 0
			#_state_maximum = 0 
			#_spawn_pos = Vector2i(5, 10)
		#
		#_: push_error("Unerwarteter Fehler: Diese Upgrade ID ist nicht definiert!")


func get_id() -> IDs:
	return _id


func get_display_name() -> String:
	return _display_name


func get_description() -> String:
	return _description


func get_price() -> int:
	return _price


func get_tilemap_position() -> Vector2i:
	return _tilemap_position


func get_state() -> int:
	return _state


func get_spawn_pos() -> Vector2i:
	return _spawn_pos


func set_state(new_state : int) -> void:
	if new_state > _state_maximum || new_state < 0:
			push_error("Unerwarteter Fehler: upgrade state out of bounds")
	_state = new_state


func get_state_maximum() -> int:
	return _state_maximum


func get_sprite() -> Sprite2D:
	return $Sprite2D


func _on_pressed() -> void:
	was_pressed.emit(self)
