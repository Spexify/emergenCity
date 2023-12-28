extends CharacterBody2D
class_name EMC_Avatar

signal arrived

@export var move_speed: float = 100
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
const SPEED: float = 300.0

## 2200 kCal Nahrung, 2000 ml Wasser pro Tag und health_bar gemessen in Prozent
var hunger_bar : int = 5
var thirst_bar : int = 5
var health_bar : int = 5

@onready var walking = $SFX/Walking

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
	if (p_target_pos.y >= position.y):
		$Sprite2D.frame = Frame.FRONTSIDE
	else:
		$Sprite2D.frame = Frame.BACKSIDE
	
	navAgent.target_position = p_target_pos
	if not walking.playing:
		walking.play()


func cancel_navigation() -> void:
	navAgent.target_position = self.position
	

## Getters für die Statutbalken vom Avatar
func get_hunger_status() -> int:
	return hunger_bar

func get_thirst_status() -> int:
	return thirst_bar
	
func get_health_status() -> int:
	return health_bar
	
	
## Setters für die Statutbalken vom Avatar
## TODO : add and subtract methods instead
func raise_hunger(hunger_status : int) -> void:
	hunger_bar += hunger_status
	
func lower_hunger(hunger_status : int) -> void:
	hunger_bar -= hunger_status
	
func raise_thirst(thirst_status : int) -> void:
	thirst_bar += thirst_status
	
func lower_thirst(thirst_status : int) -> void:
	thirst_bar -= thirst_status

func raise_health(health_status : int) -> void:
	health_bar += health_status
	
func lower_health(health_status : int) -> void:
	health_bar -= health_status


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
	walking.stop()
	arrived.emit()
