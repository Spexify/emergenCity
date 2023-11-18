extends CharacterBody2D

@export var move_speed : float = 100

const SPEED = 300.0


func _physics_process(delta):
	# Get the input direction
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
		
	)
	
	# Update velocity
	velocity = move_speed * input_direction
	
	# move_and_slide() uses the characters velocity to move them on the map
	move_and_slide()
