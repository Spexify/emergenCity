extends CharacterBody2D

@export var move_speed: float = 100
@onready var navAgent := $NavigationAgent2D as NavigationAgent2D
@onready var tileMap := $"../TileMap" as TileMap
const SPEED: float = 300.0

#func _ready():
#	navAgent.set_target_desired_distance(5.0)

func _physics_process(_delta):
	var input_direction : Vector2
	
	#Stop pathfinding-navigation, if close enough at target (set_target_desired_distance() doesn't seem to work)
	if (navAgent.distance_to_target() < 5.0): navAgent.target_position = self.position #move_speed = 0.1
	#else: move_speed = SPEED
	
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


func _unhandled_input(event):
	#var crisisPhaseNode = get_node("Chr") #get_tree().root
	
	if ((event is InputEventMouseButton && event.pressed == true)
	or (event is InputEventScreenTouch)):
		#if crisisPhaseNode.inputMode == crisisPhaseNode.INPUT_MODE.default:
			var stage = get_node("/root/CrisisPhase/Stage")
			#if navAgent.is_target_reachable(): #funzt net ganz?
			if !stage.clickedTileHasCollision(event.position):
				navAgent.target_position = event.position
