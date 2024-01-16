extends CharacterBody2D
class_name EMC_NPC

signal clicked(p_NPC: EMC_NPC)
@onready var _sprite := $Sprite2D

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func setup(p_name: String, p_spawn_pos: Vector2 = Vector2.ZERO) -> void:
	name = p_name
	#Check bounds, [0] = x-Pos
	#if (p_spawn_pos[0] < 0 || p_spawn_pos[0] > get_viewport().size[0]) || \
		#(p_spawn_pos[1] < 0 || p_spawn_pos[1] > get_viewport().size[1]):
		#printerr("SpawnPosition of NPC " + p_name + " is out of bounds!")
	
	await ready #important, otherwhise the sprite might not be instantiated yet, and thus null
	
	#MRM: You have to use CompressedTextures with load, otherwhise it doesn't work on the exported APK 
	#var sprite_image: Image = Image.load_from_file("res://res/characters/sprite_" + name.to_lower() + ".png")
	var sprite_texture: CompressedTexture2D = load("res://res/characters/sprite_" + name.to_lower() + ".png")
	_sprite.texture = sprite_texture #ImageTexture.create_from_image(sprite_image)
	
	position = p_spawn_pos


func set_frame(p_frame_idx: int) -> void:
	_sprite.frame = p_frame_idx


#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _on_dialogue_hit_box_pressed() -> void:
	clicked.emit(self)
