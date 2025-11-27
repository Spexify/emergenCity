extends CharacterBody2D
class_name EMC_Avatar
##MRM: TODO: Either the sub_ / add_ methods should check that the values are always positive, or
## they should be merged into one "change_xxx_by" method

signal arrived

signal status_updated(
	delta_food: int, new_food: int,
	delta_drink: int, new_drink: int,
	delta_health: int, new_health: int,
	delta_social: int, new_social: int,
)

signal died

const MOVE_SPEED: float = 300.0 #real movespeed set in NavAgent Node under Avoidance (Max Speed)!
const PITCH: float = 1.0

@onready var _nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var _walking_SFX := $SFX/Walking

const MAX_STATUS: int = 8 #EMC_DayMngr.TIME_PRE_DAY/3*10*3

var INIT_FOOD: int = MAX_STATUS/2
var INIT_DRINK: int = MAX_STATUS/2
var INIT_HEALTH: int = MAX_STATUS/2
var INIT_SOCIAL: int = MAX_STATUS/2

var _food_status: int = 0
var _drink_status: int = 0
var _health_status: int = 0
var _social_status: int = 0

var _food_decay: int = 1
var _drink_decay: int = 1
var _health_decay: int = 1
var _social_decay: int = 1

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
	if not _walking_SFX.playing:
		_walking_SFX.play()
	$AnimationPlayer.play("walking")

func cancel_navigation() -> void:
	_nav_agent.target_position = self.position

func consume_item(p_item : EMC_Item) -> void:
	var consumable_comps : Array[EMC_IC_Consumable]
	consumable_comps.assign(p_item.get_all_comps_of(EMC_IC_Consumable))
	
	begin_batch()
	for con : EMC_IC_Consumable in consumable_comps:
		con.consume(self)
	end_batch()

var _food_delta: int = 0
var _drink_delta: int = 0
var _health_delta: int = 0
var _social_delta: int = 0

var _batch_depth: int = 0

func begin_batch() -> void:
	_batch_depth = 1
	
func end_batch() -> void:
	_batch_depth = max(_batch_depth - 1, 0)
	if _batch_depth == 0:
		if _food_delta == 0 and _drink_delta == 0 and _health_delta == 0 and _social_delta == 0:
			return
		
		_apply_delta()

func modify_food_delta(delta: int) -> void:
	_food_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()

func modify_drink_delta(delta: int) -> void:
	_drink_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()

func modify_health_delta(delta: int) -> void:
	_health_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()
		
func modify_social_delta(delta: int) -> void:
	_social_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()

func _apply_delta() -> void:
	self._food_status += _food_delta 
	self._drink_status += _drink_delta 
	self._health_status += _health_delta 
	self._social_status += _social_delta 
	
	if self._food_status <= 0 || self._drink_status <= 0 || \
	self._health_status <= 0 :
		died.emit()
	
	status_updated.emit(
		_food_delta, self._food_status,
		_drink_delta, self._drink_status,
		_health_delta, self._health_status,
		_social_delta, self._social_status,
	)
	
	_food_delta = 0
	_drink_delta = 0
	_health_delta = 0
	_social_delta = 0

func advance_time(delta: int) -> void:
	begin_batch()
	modify_food_delta(-_food_decay)
	modify_drink_delta(-_drink_decay)
	modify_health_delta(-_health_decay)
	modify_social_delta(-_social_decay)
	end_batch()

#region old
#
### Getters für die Statutwerten vom Avatar
#func get_nutrition_status() -> int:
	#return _nutrition_value
#
#func get_unit_nutrition_status() -> int:
	#return _nutrition_value*UNIT_FACTOR_NUTRITION
	#
#func get_hydration_status() -> int:
	#return _hydration_value
	#
#func get_unit_hydration_status() -> int:
	#return _hydration_value*UNIT_FACTOR_HYDRATION
	#
#func get_health_status() -> int:
	#return _health_value
	#
#func get_unit_health_status() -> int:
	#return _health_value*UNIT_FACTOR_HEALTH
	#
#func get_happiness_status() -> int:
	#return _happiness_value
	#
#func get_unit_happiness_status() -> int:
	#return _happiness_value * UNIT_FACTOR_HAPPINESS
		#
######################## Setters für die Statutbalken vom Avatar ############################
#
#func update_nutrition(value : int = 1) -> void:
	#var new_value : int = _nutrition_value + value
	#if  new_value <= MAX_VITALS_NUTRITION and new_value >= 0:
		#_nutrition_value = new_value
	#elif new_value < 0:
		#_nutrition_value = 0
	#elif new_value > MAX_VITALS_NUTRITION:
		#_nutrition_value = MAX_VITALS_NUTRITION
		#
	#nutrition_updated.emit(get_unit_nutrition_status())
#
#func add_nutrition(nutrition_change : int = 1) -> void: 
	#if _nutrition_value + nutrition_change <= MAX_VITALS_NUTRITION:
		#_nutrition_value += nutrition_change
		#nutrition_updated.emit(get_unit_nutrition_status())
	#else: 
		#_nutrition_value = MAX_VITALS_NUTRITION
		#nutrition_updated.emit(get_unit_nutrition_status())
#
#
#func sub_nutrition(nutrition_change : int = 1) -> bool:
	#if _nutrition_value - nutrition_change < 0 or _nutrition_value < 0:
		#_nutrition_value = 0
		#nutrition_updated.emit(get_unit_nutrition_status()) 
		#return false
	#else:
		#_nutrition_value -= nutrition_change
		#nutrition_updated.emit(get_unit_nutrition_status())
		#return true
	#
#func update_hydration(value : int = 1) -> void:
	#var new_value : int = _hydration_value + value
	#if  new_value <= MAX_VITALS_HYDRATION and new_value >= 0:
		#_hydration_value = new_value
	#elif new_value < 0:
		#_hydration_value = 0
	#elif new_value > MAX_VITALS_HYDRATION:
		#_hydration_value = MAX_VITALS_HYDRATION
		#
	#hydration_updated.emit(get_unit_hydration_status())
#
#func add_hydration(hydration_change : int = 1) -> void:
	#if _hydration_value + hydration_change <= MAX_VITALS_HYDRATION:
		#_hydration_value += hydration_change
		#hydration_updated.emit(get_unit_hydration_status())
	#else:
		#_hydration_value = MAX_VITALS_HYDRATION
		#hydration_updated.emit(get_unit_hydration_status())
	#
#func sub_hydration(hydration_change : int = 1) -> bool:
	#if _hydration_value - hydration_change < 0 or _hydration_value < 0:
		#_hydration_value = 0
		#hydration_updated.emit(get_unit_hydration_status())
		#return false
	#else:
		#_hydration_value -= hydration_change
		#hydration_updated.emit(get_unit_hydration_status())
		#return true
#
#func update_health(value : int = 1) -> void:
	#var new_value : int = _health_value + value
	#if  new_value <= MAX_VITALS_HEALTH and new_value >= 0:
		#_health_value = new_value
	#elif new_value < 0:
		#_health_value = 0
	#elif new_value > MAX_VITALS_HEALTH:
		#_health_value = MAX_VITALS_HEALTH
		#
	#health_updated.emit(get_unit_health_status())
#
#func add_health(health_change : int = 1) -> void:
	#if _health_value + health_change <= MAX_VITALS_HEALTH: 
		#_health_value += health_change
		#health_updated.emit(get_unit_health_status())
	#else: 
		#_health_value = MAX_VITALS_HEALTH
		#health_updated.emit(get_unit_health_status())
#
#
#func sub_health(health_change : int = 1) -> bool:
	#if health_change < 0:
		#health_change *= -1 
	#if _health_value - health_change < 0 or _health_value < 0:
		#_health_value = 0
		#health_updated.emit(get_unit_health_status())
		#return false
	#else:
		#_health_value -= health_change
		#health_updated.emit(get_unit_health_status())
		#return true
#
#func update_happiness(value : int = 1) -> void:
	#var new_value : int = _happiness_value + value
	#if  new_value <= MAX_VITALS_HAPPINESS and new_value >= 0:
		#_happiness_value = new_value
	#elif new_value < 0:
		#_happiness_value = 0
	#elif new_value > MAX_VITALS_HAPPINESS:
		#_happiness_value = MAX_VITALS_HAPPINESS
		#
	#happiness_updated.emit(get_unit_happiness_status())
#
#func add_happiness(happiness_change : int = 1) -> void:
	#if _happiness_value + happiness_change <= MAX_VITALS_HAPPINESS: 
		#_happiness_value += happiness_change
		#happiness_updated.emit(get_unit_happiness_status())
	#else: 
		#_happiness_value = MAX_VITALS_HAPPINESS
		#happiness_updated.emit(get_unit_happiness_status())
#
#
#func sub_happiness(happiness_change : int = 1) -> bool:
	#if happiness_change < 0:
		#happiness_change *= -1 
	#if _happiness_value - happiness_change < 0 or _happiness_value < 0:
		#_happiness_value = 0
		#happiness_updated.emit(get_unit_happiness_status())
		#return false
	#else:
		#_happiness_value -= happiness_change
		#happiness_updated.emit(get_unit_happiness_status())
		#return true
#
#
#func refresh_vitals() -> void:
	#nutrition_updated.emit(get_unit_nutrition_status())
	#hydration_updated.emit(get_unit_hydration_status())
	#health_updated.emit(get_unit_health_status())
	#happiness_updated.emit(get_unit_happiness_status())

#endregion

## MRM: Naming idea: Could be renamed into "serialize()" as it's not really the saving itself,
## but "serializing" the object data into a format that can be saved in a file
func save() -> Dictionary:
	var some_position : Vector2 = get_global_position()

	var data : Dictionary = {
		"node_path": get_path(),
		"food_status": _food_status,
		"drink_status": _drink_status,
		"health_status": _health_status,
		"social_status": _social_status,
		"x-position": some_position.x,
		"y-position": some_position.y
	}
	return data


func load_state(data : Dictionary) -> void:
	_food_status = data.get("food_status", INIT_FOOD)
	_drink_status = data.get("drink_status", INIT_DRINK)
	_health_status = data.get("health_status", INIT_HEALTH)
	_social_status = data.get("social_status", INIT_SOCIAL)#
	_apply_delta()
	
	var some_position : Vector2 = Vector2(data.get("x-position", 277), data.get("y-position", 601))
	set_global_position(some_position)

func get_home() -> void:
	EMC_StageMngr
	set_global_position(Vector2i(250, 750))

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	self._food_status = INIT_FOOD 
	self._drink_status = INIT_DRINK 
	self._health_status = INIT_HEALTH 
	self._social_status = INIT_SOCIAL 
	
	_apply_delta()
	SettingsGUI.avatar_sprite_changed.connect(_on_new_avatar_sprite_changed)
	_on_new_avatar_sprite_changed(SettingsGUI.get_avatar_sprite_suffix()) #init
	$AnimationPlayer.play("idle")

func _process(p_delta: float) -> void:
	#Set frame to direction that character is currently walking in
	if !_nav_agent.is_navigation_finished():
		if to_local(_nav_agent.get_next_path_position()).y > 0:
			$Sprite2D.frame = Frame.FRONTSIDE
		else:
			$Sprite2D.frame = Frame.BACKSIDE


func _physics_process(_delta: float) -> void:
	var input_direction: Vector2

	if (_nav_agent.is_navigation_finished()):
		#Keyboard-Input only relevant if no Pathfinding-Direction, so it's not mixed up
		# Get the input direction
		input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	else: #Navigation via Pathfinding
		input_direction = position.direction_to(_nav_agent.get_next_path_position()) #.normalized()
	
	# Update velocity
	var new_velocity := MOVE_SPEED * input_direction
	_nav_agent.set_velocity(new_velocity)

# NOTICE: target reched can only be emitted if path desired distance if lower or equal to Traget desired distance
func _on_navigation_target_reached() -> void:
	_walking_SFX.stop()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("idle")
	scale = Vector2(1.0, 1.0)
	arrived.emit()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide() #uses the characters velocity to move them on the map

func _on_new_avatar_sprite_changed(p_avatar_sprite_suffix: String) -> void:
	$Sprite2D.texture = \
		load("res://assets/characters/sprite_avatar_" + p_avatar_sprite_suffix + ".png")
