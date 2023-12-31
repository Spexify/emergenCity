extends CharacterBody2D
class_name EMC_Avatar

signal arrived

@export var move_speed: float = 100
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
const SPEED: float = 300.0

## 2200 kCal Nahrung, 2000 ml Wasser pro Tag und _health_bar gemessen in Prozent
## working in untis of 4
var _hunger_bar : int = 2
var _thirst_bar : int = 2
var _health_bar : int = 2
const MAX_VITALS = 4

@onready var walking := $SFX/Walking

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
	return _hunger_bar

func get_thirst_status() -> int:
	return _thirst_bar
	
func get_health_status() -> int:
	return _health_bar
	
	
## Setters für die Statutbalken vom Avatar
func add_hunger(hunger_status : int) -> void:
	if _hunger_bar + hunger_status > MAX_VITALS:
		_hunger_bar = hunger_status
	else:
		_hunger_bar += hunger_status
	
func sub_hunger(hunger_status : int) -> bool:
	if _hunger_bar - hunger_status < 0 or _hunger_bar < 0:
		return false
	else:
		_hunger_bar -= hunger_status
		return true
	
func add_thirst(thirst_status : int) -> void:
	if _thirst_bar + thirst_status > MAX_VITALS:
		_thirst_bar = thirst_status
	else:
		_thirst_bar += thirst_status
	
func sub_thirst(thirst_status : int) -> bool:
	if _thirst_bar - thirst_status < 0 or _thirst_bar < 0:
		return false
	else:
		_thirst_bar -= thirst_status
		return true

func add_health(health_status : int) -> void:
	if _health_bar + health_status > MAX_VITALS:
		_health_bar = health_status
	else:
		_health_bar += health_status
	
func sub_health(health_status : int) -> bool:
	if _health_bar - health_status < 0 or _health_bar < 0:
		return false
	else:
		_health_bar -= health_status
		return true


#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _physics_process(_delta: float) -> void:
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
func _on_navigation_agent_2d_navigation_finished() -> void:
	walking.stop() #Name should be more precise. Walking could be an animation or a state-object
	arrived.emit()
