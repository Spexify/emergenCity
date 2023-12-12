extends CharacterBody2D
class_name EMC_Avatar

signal arrived

@export var move_speed: float = 100
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
const SPEED: float = 300.0

enum Frame{
	FRONTSIDE = 0,
	BACKSIDE = 1
}

#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Das Navigationsziel des Avatars setzen
##TODO: In TechDoku aufnehmen: navAgent.is_target_reachable(): #funzt net
func set_target(p_target_pos: Vector2) -> void:
	if (p_target_pos == position):
		return
	if (p_target_pos.y > position.y):
		$Sprite2D.frame = Frame.FRONTSIDE
	else:
		$Sprite2D.frame = Frame.BACKSIDE
	
	navAgent.target_position = p_target_pos


func cancel_navigation() -> void:
	navAgent.target_position = self.position


#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _physics_process(_delta):
	var input_direction: Vector2
	
	#Stop pathfinding-navigation, if close enough at target (set_target_desired_distance() doesn't seem to work)
	if (navAgent.distance_to_target() < 5.0):
		#arrived.emit()
		cancel_navigation()
	if (navAgent.is_navigation_finished()):
		#Keyboard-Input only relevant if no Pathfinding-Direction, so it's not mixed up
		# Get the input direction
		input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	else: #Navigation via Pathfinding
		input_direction = to_local(navAgent.get_next_path_position()).normalized()
	
	# Update velocity
	velocity = move_speed * input_direction
	
	# move_and_slide() uses the characters velocity to move them on the map
	move_and_slide()


## target_reached() doesn't work for whatever reason
func _on_navigation_agent_2d_navigation_finished():
	arrived.emit()
