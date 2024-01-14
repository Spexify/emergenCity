extends CharacterBody2D
class_name EMC_NPC

signal clicked(p_NPC: EMC_NPC)
@onready var _sprite := $Sprite2D

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func setup(p_name: String, p_spawn_pos: Vector2 = Vector2.ZERO) -> void:
	name = p_name
	await ready #important, otherwhise the sprite might not be instantiated yet, and thus null
	var sprite_image: Image = Image.load_from_file("res://res/characters/sprite_" + name.to_lower() + ".png")
	_sprite.texture = ImageTexture.create_from_image(sprite_image)
	
	position = p_spawn_pos


func set_frame(p_frame_idx: int) -> void:
	_sprite.frame = p_frame_idx


#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _physics_process(delta: float) -> void:
	#print("NPC y: " + str(position[1]))
	pass


#func _unhandled_input(p_event: InputEvent) -> void:
	#if ((p_event is InputEventMouseButton && p_event.pressed == true)
	#or (p_event is InputEventScreenTouch)):
		#print("NPC was clicked")


func _on_dialogue_hit_box_pressed() -> void:
	clicked.emit(self)
