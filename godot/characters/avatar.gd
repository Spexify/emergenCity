extends CharacterBody2D
class_name EMC_Avatar

signal arrived
signal nutrition_updated(p_new_value: int)
signal hydration_updated(p_new_value: int)
signal health_updated(p_new_value: int)

@export var move_speed: float = 100
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
const SPEED: float = 300.0

## 2200 kCal Nahrung, 2000 ml Wasser pro Tag und _health_value gemessen in Prozent
## working in untis of 4
var _nutrition_value : int = MAX_VITALS
var _hydration_value : int = 2
var _health_value : int = 2
const MAX_VITALS = 4
#MRM: Unit sollte direct von den Components verwendet werden:
const UNIT_FACTOR_NUTRITION: int = EMC_IC_Food.UNIT_FACTOR #550 #food Unit = 550 kcal 
const UNIT_FACTOR_HYDRATION: int = 500 #water Unit = 500 ml
const UNIT_FACTOR_HEALTH: int = 25 #health Unit = 25 percent

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
	

## Getters für die Statutwerten vom Avatar
func get_nutrition_status() -> int:
	return _nutrition_value

func get_unit_nutrition_status() -> int:
	return _nutrition_value*UNIT_FACTOR_NUTRITION
	
func get_hydration_status() -> int:
	return _hydration_value
	
func get_unit_hydration_status() -> int:
	return _hydration_value*UNIT_FACTOR_HYDRATION
	
func get_health_status() -> int:
	return _health_value
	
func get_unit_health_status() -> int:
	return _health_value*UNIT_FACTOR_HEALTH
	
	
## Setters für die Statutbalken vom Avatar
#MRM: "nutrition status": name should make clear, that it's the difference/change/addition in value:
func add_nutrition(nutrition_status : int) -> void: 
	if _nutrition_value + nutrition_status <= MAX_VITALS: #MRM: Fixed bug
		_nutrition_value += nutrition_status
		nutrition_updated.emit(_nutrition_value)


func sub_nutrition(nutrition_status : int) -> bool:
	if _nutrition_value - nutrition_status < 0 or _nutrition_value < 0:
		#MRM: Ups, das emit muss vor dem return passieren, da es sonst nie aufgerufen wird:
		nutrition_updated.emit(_nutrition_value) 
		return false
	else:
		_nutrition_value -= nutrition_status
		#MRM: Ups, das emit muss vor dem return passieren, da es sonst nie aufgerufen wird:
		nutrition_updated.emit(_nutrition_value)
		return true
	
func add_hydration(hydration_status : int) -> void:
	if _hydration_value + hydration_status > MAX_VITALS:
		_hydration_value = hydration_status
	else:
		_hydration_value += hydration_status
	hydration_updated.emit(_hydration_value)
	
func sub_hydration(hydration_status : int) -> bool:
	if _hydration_value - hydration_status < 0 or _hydration_value < 0:
		return false
	else:
		_hydration_value -= hydration_status
		return true
	hydration_updated.emit(_hydration_value)

func add_health(health_status : int) -> void:
	if _health_value + health_status > MAX_VITALS:
		_health_value = health_status
	else:
		_health_value += health_status
	health_updated.emit(_health_value)
	
func sub_health(health_status : int) -> bool:
	if _health_value - health_status < 0 or _health_value < 0:
		return false
	else:
		_health_value -= health_status
		return true
	health_updated.emit(_health_value)


#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _ready() -> void:
	nutrition_updated.emit(_nutrition_value)
	hydration_updated.emit(_hydration_value)
	health_updated.emit(_health_value)


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
