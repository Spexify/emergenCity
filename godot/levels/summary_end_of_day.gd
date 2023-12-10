extends Control

signal opened
signal closed

# Assuming some variables
var foodBar : int = 10
var waterBar : int = 2
var hygieneBar : int = 4

var summaryWindow : PackedScene = preload("res://levels/summary_end_of_day.tscn")

	
func _ready():
	_summary_end_of_day_closed()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _summary_end_of_day_closed():
	get_tree().paused = false
	$GUI.hide()
	$BtnBackpack.show()
	pass # Replace with function body.


func _summary_end_of_day_opened():
	get_tree().paused = true
	$GUI.show()
	$BtnBackpack.hide()
	pass # Replace with function body.

# Function to handle "Eat" button press
func _on_eat_button_pressed():
	# Implement the logic for eating here
	# Access inventory, depending on item chose (uncooked or cooked raviolli), fit food bar changes
	print("Eat button pressed")

# Function to handle "Drink" button press
func _on_drink_button_pressed():
	# Implement the logic for drinking here
	# Access inventory, depending on item chose (clean or unfiltered water), fit water bar changes
	print("Drink button pressed")

# Function to handle "Continue" button press
func _continue_button_pressed():
	# fill function
	# show a windowd with stats and ctart new crisis day
	pass
