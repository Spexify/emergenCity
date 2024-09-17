extends CharacterBody2D
class_name EMC_NPC

signal clicked(p_NPC: EMC_NPC)

@onready var _sprite := $Sprite2D
@onready var _collision_circle := $CollisionCircle
@onready var _dialogue_hitbox := $DialogueHitbox

var _dialogue_pitch: float = 1.0 #TODO: link this to the dialogue_GUI.gd
var _trade_bid: EMC_TradeMngr.TradeBid
var _inventory : EMC_Inventory = EMC_Inventory.new(15)

########################################## PUBLIC METHODS ##########################################

func setup(p_name: String, p_spawn_pos: Vector2 = Vector2.ZERO) -> void:
	name = p_name
	#Check bounds, [0] = x-Pos
	#if (p_spawn_pos[0] < 0 || p_spawn_pos[0] > get_viewport().size[0]) || \
		#(p_spawn_pos[1] < 0 || p_spawn_pos[1] > get_viewport().size[1]):
		#printerr("SpawnPosition of NPC " + p_name + " is out of bounds!")	
	
	position = p_spawn_pos
	
	_inventory.add_new_item(1)
	
func _ready() -> void:
	var sprite_texture: CompressedTexture2D = load("res://res/sprites/characters/sprite_" + name.to_lower() + ".png")
	_sprite.texture = sprite_texture
	
	$AnimationPlayer.play("idle")

func get_inventory() -> EMC_Inventory:
	return _inventory

func set_frame(p_frame_idx: int) -> void:
	_sprite.frame = p_frame_idx

func deactivate() -> void:
	hide()
	_collision_circle.disabled = true
	_dialogue_hitbox.disabled = true

func activate() -> void:
	show()
	_collision_circle.disabled = false
	_dialogue_hitbox.disabled = false

func set_trade_bid(p_trade_bid: EMC_TradeMngr.TradeBid) -> void:
	_trade_bid = p_trade_bid

func get_trade_bid() -> EMC_TradeMngr.TradeBid:
	return _trade_bid

func _to_string() -> String:
	return str(name) + " @ " + str(position);

########################################## PRIVATE METHODS #########################################
func _on_dialogue_hit_box_pressed() -> void:
	clicked.emit(self)
