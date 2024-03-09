extends CharacterBody2D
class_name EMC_Avatar
##MRM: TODO: Either the sub_ / add_ methods should check that the values are always positive, or
## they should be merged into one "change_xxx_by" method


signal arrived
signal nutrition_updated(p_new_value: int)
signal hydration_updated(p_new_value: int)
signal health_updated(p_new_value: int)
signal happiness_updated(p_new_value: int)

const MOVE_SPEED: float = 300.0 #real movespeed set in NavAgent Node under Avoidance (Max Speed)!

#MRM: Unit sollte direct von den Components verwendet werden:
const UNIT_FACTOR_NUTRITION: int = EMC_IC_Food.UNIT_FACTOR
const UNIT_FACTOR_HYDRATION: int = EMC_IC_Drink.UNIT_FACTOR
const UNIT_FACTOR_HEALTH: int = 10 #health Unit in percent #MRM: Changed temp. so you don't die to early in tests
const UNIT_FACTOR_HAPPINESS: int = 10

const MAX_VITALS_NUTRITION = 10
const MAX_VITALS_HYDRATION = 10
const MAX_VITALS_HEALTH = 10
const MAX_VITALS_HAPPINESS = 10

const INIT_NUTRITION_VALUE : int = MAX_VITALS_NUTRITION/2
const INIT_HYDRATION_VALUE : int = MAX_VITALS_NUTRITION/2
const INIT_HEALTH_VALUE : int = MAX_VITALS_NUTRITION/2
const INIT_HAPPINESS_VALUE : int = MAX_VITALS_NUTRITION/2

@onready var _nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var walking := $SFX/Walking

## 2200 kCal Nahrung, 2000 ml Wasser pro Tag, _health_value und _happinness_value gemessen in Prozent
## working in untis of 4
var _nutrition_value : int = INIT_NUTRITION_VALUE
var _hydration_value : int = INIT_HYDRATION_VALUE
var _health_value : int = INIT_HEALTH_VALUE
var _happiness_value : int = INIT_HAPPINESS_VALUE


enum Frame{
	FRONTSIDE = 0,
	BACKSIDE = 1
}

########################################## PUBLIC METHODS ##########################################
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
	
func get_happiness_status() -> int:
	return _happiness_value
	
func get_unit_happiness_status() -> int:
	return _happiness_value * UNIT_FACTOR_HAPPINESS
		
####################### Setters für die Statutbalken vom Avatar ############################

func add_nutrition(nutrition_change : int = 1) -> void: 
	if _nutrition_value + nutrition_change <= MAX_VITALS_NUTRITION:
		_nutrition_value += nutrition_change
		nutrition_updated.emit(get_unit_nutrition_status())
	else: 
		_nutrition_value = MAX_VITALS_NUTRITION
		nutrition_updated.emit(get_unit_nutrition_status())


func sub_nutrition(nutrition_change : int = 1) -> bool:
	if _nutrition_value - nutrition_change < 0 or _nutrition_value < 0:
		_nutrition_value = 0
		nutrition_updated.emit(get_unit_nutrition_status()) 
		return false
	else:
		_nutrition_value -= nutrition_change
		nutrition_updated.emit(get_unit_nutrition_status())
		return true
	
func add_hydration(hydration_change : int = 1) -> void:
	if _hydration_value + hydration_change <= MAX_VITALS_HYDRATION:
		_hydration_value += hydration_change
		hydration_updated.emit(get_unit_hydration_status())
	else:
		_hydration_value = MAX_VITALS_HYDRATION
		hydration_updated.emit(get_unit_hydration_status())
	
func sub_hydration(hydration_change : int = 1) -> bool:
	if _hydration_value - hydration_change < 0 or _hydration_value < 0:
		_hydration_value = 0
		hydration_updated.emit(get_unit_hydration_status())
		return false
	else:
		_hydration_value -= hydration_change
		hydration_updated.emit(get_unit_hydration_status())
		return true

func add_health(health_change : int = 1) -> void:
	if _health_value + health_change <= MAX_VITALS_HEALTH: 
		_health_value += health_change
		health_updated.emit(get_unit_health_status())
	else: 
		_health_value = MAX_VITALS_HEALTH
		health_updated.emit(get_unit_health_status())


func sub_health(health_change : int = 1) -> bool:
	if health_change < 0:
		health_change *= -1 
	if _health_value - health_change < 0 or _health_value < 0:
		_health_value = 0
		health_updated.emit(get_unit_health_status())
		return false
	else:
		_health_value -= health_change
		health_updated.emit(get_unit_health_status())
		return true


func add_happiness(happiness_change : int = 1) -> void:
	if _happiness_value + happiness_change <= MAX_VITALS_HAPPINESS: 
		_happiness_value += happiness_change
		happiness_updated.emit(get_unit_happiness_status())
	else: 
		_happiness_value = MAX_VITALS_HAPPINESS
		happiness_updated.emit(get_unit_happiness_status())


func sub_happiness(happiness_change : int = 1) -> bool:
	if happiness_change < 0:
		happiness_change *= -1 
	if _happiness_value - happiness_change < 0 or _happiness_value < 0:
		_happiness_value = 0
		happiness_updated.emit(get_unit_happiness_status())
		return false
	else:
		_happiness_value -= happiness_change
		happiness_updated.emit(get_unit_happiness_status())
		return true

func refresh_vitals() -> void:
	nutrition_updated.emit(get_unit_nutrition_status())
	hydration_updated.emit(get_unit_hydration_status())
	health_updated.emit(get_unit_health_status())
	happiness_updated.emit(get_unit_happiness_status())

## MRM: Naming idea: Could be renamed into "serialize()" as it's not really the saving itself,
## but "serializing" the object data into a format that can be saved in a file
func save() -> Dictionary:

	var some_position : Vector2 = get_global_position()

	var data : Dictionary = {
		"node_path": get_path(),
		"nutrition_value": _nutrition_value,
		"hydration_value": _hydration_value,
		"health_value": _health_value,
		"happiness_value": _happiness_value,
		"x-position": some_position.x,
		"y-position": some_position.y
	}
	return data


func load_state(data : Dictionary) -> void:
	_nutrition_value = data.get("nutrition_value", INIT_NUTRITION_VALUE)
	nutrition_updated.emit(get_unit_nutrition_status())
	_hydration_value = data.get("hydration_value", INIT_HYDRATION_VALUE)
	hydration_updated.emit(get_unit_hydration_status())
	_health_value = data.get("health_value", INIT_HEALTH_VALUE)
	health_updated.emit(get_unit_health_status())
	_happiness_value = data.get("happiness_value", INIT_HAPPINESS_VALUE)
	happiness_updated.emit(get_unit_happiness_status())
	
	var some_position : Vector2 = Vector2(data.get("x-position", 277), data.get("y-position", 601))
	set_global_position(some_position)


func get_home() -> void:
	EMC_StageMngr
	set_global_position(Vector2i(250, 750))


## After each day, the vitals of the avatar have to be adjusted
func update_vitals() -> void:
	sub_nutrition(3) 
	sub_hydration(3)
	sub_health(1)
	sub_happiness(1)


########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	nutrition_updated.emit(get_unit_nutrition_status())
	hydration_updated.emit(get_unit_hydration_status())
	health_updated.emit(get_unit_health_status())
	happiness_updated.emit(get_unit_happiness_status())
	SettingsGUI.avatar_sprite_changed.connect(_on_new_avatar_sprite_changed)
	_on_new_avatar_sprite_changed(SettingsGUI.get_avatar_sprite_suffix()) #init


func _process(p_delta: float) -> void:
	#Set frame to direction that character is currently walking in
	if !_nav_agent.is_navigation_finished():
		if to_local(_nav_agent.get_next_path_position()).y > 0:
			$Sprite2D.frame = Frame.FRONTSIDE
		else:
			$Sprite2D.frame = Frame.BACKSIDE


func _physics_process(_delta: float) -> void:
	var input_direction: Vector2
	const MIN_DISTANCE_TO_TARGET: float = 5.0
	
	#Stop pathfinding-navigation, if close enough at target (set_target_desired_distance() doesn't seem to work)
	if (_nav_agent.distance_to_target() < MIN_DISTANCE_TO_TARGET):
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


func _on_new_avatar_sprite_changed(p_avatar_sprite_suffix: String) -> void:
	$Sprite2D.texture = \
		load("res://res/sprites/characters/sprite_avatar_" + p_avatar_sprite_suffix + ".png")


