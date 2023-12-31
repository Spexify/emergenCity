extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_avatar_nutrition_updated(p_new_value: int) -> void:
	$VBoxContainer/HBoxContainer2/NutritionBar.set_value_no_signal(p_new_value)

func _on_avatar_hydration_updated(p_new_value: int) -> void:
	$VBoxContainer/HBoxContainer/HydrationBar.set_value_no_signal(p_new_value)

func _on_avatar_health_updated(p_new_value: int) -> void:
	$VBoxContainer/HBoxContainer3/HealthBar.set_value_no_signal(p_new_value)

