extends Node2D

var inventoryScene : PackedScene = preload("res://items/inventory.tscn")

## This is the main node holding all importent informations.
## It will only work when the you run the main scene.
@onready var main : Node = get_node("/root/main")

# Called when the node enters the scene tree for the first time.
func _ready():
	if main == null:
		print("The main node could not be found. 
		This may be because you ran the crisis scene directly!")
	
	_on_inventory_closed()
	
##### The following Code is not a final design
##### It allows DayCircle to acces and check data

	$DayCycle.parent = self
	$DayCycle.get_avatar_rect = $CharacterBody2D/Sprite2D.get_rect
	$DayCycle._index_actions()

func day_time_equal(time):
	return $DayCycle.current_time == time
	
func day_time_greater(time):
	return $DayCycle.current_time > time

func player_speed_set(speed: float):
	$CharacterBody2D.move_speed = speed
	
func player_speed_add(speed: float):
	$CharacterBody2D.move_speed += speed
	
##### End of experimantal code

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_inventory_closed():
	get_tree().paused = false
	$GUI.hide()
	$BtnBackpack.show()
	pass # Replace with function body.


func _on_inventory_opened():
	get_tree().paused = true
	$GUI.show()
	$BtnBackpack.hide()
	pass # Replace with function body.
