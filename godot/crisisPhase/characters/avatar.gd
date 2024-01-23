extends CharacterBody2D
class_name EMC_Avatar

signal arrived
signal nutrition_updated(p_new_value: int)
signal hydration_updated(p_new_value: int)
signal health_updated(p_new_value: int)

const MOVE_SPEED: float = 300.0 #real movespeed set in NavAgent Node under Avoidance (Max Speed)!
const MAX_VITALS = 4
#MRM: Unit sollte direct von den Components verwendet werden:
const UNIT_FACTOR_NUTRITION: int = EMC_IC_Food.UNIT_FACTOR #550 #food Unit = 550 kcal 
const UNIT_FACTOR_HYDRATION: int = EMC_IC_Drink.UNIT_FACTOR #water Unit = 500 ml
const UNIT_FACTOR_HEALTH: int = 25 #health Unit = 25 percent

const INIT_NUTRITION_VALUE : int = MAX_VITALS
const INIT_HYDRATION_VALUE : int = 2
const INIT_HEALTH_VALUE : int = 2

@onready var _nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var walking := $SFX/Walking

## 2200 kCal Nahrung, 2000 ml Wasser pro Tag und _health_value gemessen in Prozent
## working in untis of 4
var _nutrition_value : int = INIT_NUTRITION_VALUE
var _hydration_value : int = INIT_HYDRATION_VALUE
var _health_value : int = INIT_HEALTH_VALUE


enum Frame{
	FRONTSIDE = 0,
	BACKSIDE = 1
}

#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Das Navigationsziel des Avatars setzen
##TODO: In TechDoku aufnehmen: _nav_agent.is_target_reachable(): #funzt net
func set_target(p_target_pos: Vector2) -> void:
	if (p_target_pos == position):
		return
	
	_nav_agent.target_position = p_target_pos
	if not walking.playing:
		walking.play()


func cancel_navigation() -> void:
	_nav_agent.target_position = self.position
	

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
func add_nutrition(nutrition_change : int = 1) -> void: 
	if _nutrition_value + nutrition_change <= MAX_VITALS: #MRM: Fixed bug
		_nutrition_value += nutrition_change
		nutrition_updated.emit(_nutrition_value)


func sub_nutrition(nutrition_change : int = 1) -> bool:
	if _nutrition_value - nutrition_change < 0 or _nutrition_value < 0:
		nutrition_updated.emit(_nutrition_value) 
		return false
	else:
		_nutrition_value -= nutrition_change
		nutrition_updated.emit(_nutrition_value)
		return true
	
func add_hydration(hydration_change : int = 1) -> void:
	if _hydration_value + hydration_change <= MAX_VITALS:
		_hydration_value += hydration_change
		hydration_updated.emit(_hydration_value)
	
func sub_hydration(hydration_change : int = 1) -> bool:
	if _hydration_value - hydration_change < 0 or _hydration_value < 0:
		hydration_updated.emit(_hydration_value)
		return false
	else:
		_hydration_value -= hydration_change
		hydration_updated.emit(_hydration_value)
		return true

func add_health(health_change : int = 1) -> void:
	if _health_value + health_change <= MAX_VITALS: 
		_health_value += health_change
		health_updated.emit(_health_value)
	
func sub_health(health_change : int = 1) -> bool:
	if _health_value - health_change < 0 or _health_value < 0:
		health_updated.emit(_health_value)
		return false
	else:
		_health_value -= health_change
		health_updated.emit(_health_value)
		return true


## MRM: Naming idea: Could be renamed into "serialize()" as it's not really the saving itself,
## but "serializing" the object data into a format that can be saved in a file
func save() -> Dictionary:

	var some_position : Vector2 = get_global_position()

	var data : Dictionary = {
		"node_path": get_path(),
		"nutrition_value": _nutrition_value,
		"hydration_value": _hydration_value,
		"health_value": _health_value,
		"x-position": some_position.x,
		"y-position": some_position.y
	}
	return data


func load_state(data : Dictionary) -> void:
	_nutrition_value = data.get("nutrition_value", INIT_NUTRITION_VALUE)
	nutrition_updated.emit(_nutrition_value)
	_hydration_value = data.get("hydration_value", INIT_HYDRATION_VALUE)
	hydration_updated.emit(_hydration_value)
	_health_value = data.get("health_value", INIT_HEALTH_VALUE)	
	health_updated.emit(_health_value)
	
	var some_position : Vector2 = Vector2(data.get("x-position", 277), data.get("y-position", 601))
	set_global_position(some_position)
	

#----------------------------------------- PRIVATE METHODS -----------------------------------------
func _ready() -> void:
	nutrition_updated.emit(_nutrition_value)
	hydration_updated.emit(_hydration_value)
	health_updated.emit(_health_value)


func _process(p_delta: float) -> void:
	#Set frame to direction that character is currently walking in
	if !_nav_agent.is_navigation_finished():
		if to_local(_nav_agent.get_next_path_position()).y > 0:
			$Sprite2D.frame = Frame.FRONTSIDE
		else:
			$Sprite2D.frame = Frame.BACKSIDE


func _physics_process(_delta: float) -> void:
	var input_direction: Vector2
	
	#Stop pathfinding-navigation, if close enough at target (set_target_desired_distance() doesn't seem to work)
	if (_nav_agent.distance_to_target() < 5.0):
		#arrived.emit()
		cancel_navigation()
	if (_nav_agent.is_navigation_finished()):
		#Keyboard-Input only relevant if no Pathfinding-Direction, so it's not mixed up
		# Get the input direction
		input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	else: #Navigation via Pathfinding
		input_direction = to_local(_nav_agent.get_next_path_position()).normalized()
	
	# Update velocity
	velocity = MOVE_SPEED * input_direction
	#print(velocity)
	_nav_agent.set_velocity(velocity)


## target_reached() doesn't work for whatever reason
func _on_navigation_agent_2d_navigation_finished() -> void:
	walking.stop() #Name should be more precise. Walking could be an animation or a state-object
	arrived.emit()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	# move_and_slide() uses the characters velocity to move them on the map
	#print(velocity)
	move_and_slide()
