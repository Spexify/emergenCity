extends CharacterBody2D
class_name EMC_NPC

signal clicked(p_NPC: EMC_NPC)
@onready var _sprite := $Sprite2D
@onready var _collision_circle := $CollisionCircle
@onready var _dialogue_hitbox := $DialogueHitbox

var _dialogue_pitch: float = 1.0 #TODO: link this to the dialogue_GUI.gd
var _trade_bid: EMC_TradeMngr.TradeBid

########################################## PUBLIC METHODS ##########################################
func setup(p_name: String, p_spawn_pos: Vector2 = Vector2.ZERO) -> void:
	name = p_name
	#Check bounds, [0] = x-Pos
	#if (p_spawn_pos[0] < 0 || p_spawn_pos[0] > get_viewport().size[0]) || \
		#(p_spawn_pos[1] < 0 || p_spawn_pos[1] > get_viewport().size[1]):
		#printerr("SpawnPosition of NPC " + p_name + " is out of bounds!")
	
	await ready #important, otherwhise the sprite might not be instantiated yet, and thus null
	
	#MRM: You have to use CompressedTextures with load, otherwhise it doesn't work on the exported APK 
	var sprite_texture: CompressedTexture2D = load("res://res/sprites/characters/sprite_" + name.to_lower() + ".png")
	_sprite.texture = sprite_texture
	
	position = p_spawn_pos


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

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	$AnimationPlayer.play("idle")


func _on_dialogue_hit_box_pressed() -> void:
	clicked.emit(self)
