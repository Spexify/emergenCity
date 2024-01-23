extends Control


# Called when the node enters the scene tree for the first time.
# TODO : Karina
func _ready() -> void:
	var sb := StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color("ff0000")
	#$VBoxContainer/HBoxContainer2/NutritionBar.add_child(sb)
	#$VBoxContainer/HBoxContainer2/NutritionBar.draw_style_box(sb, Rect2(30,30,100,20))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_avatar_nutrition_updated(p_new_value: int) -> void:
	var perc: int = float(p_new_value) / EMC_Avatar.MAX_VITALS * 100 #float() Casting wichtig!
	$HBoxContainer5/VBoxContainer/HBoxContainer2/NutritionBar.set_value_no_signal(perc)

func _on_avatar_hydration_updated(p_new_value: int) -> void:
	var perc: int = float(p_new_value) / EMC_Avatar.MAX_VITALS * 100 #float() Casting wichtig!
	$HBoxContainer5/VBoxContainer/HBoxContainer/HydrationBar.set_value_no_signal(perc)

func _on_avatar_health_updated(p_new_value: int) -> void:
	var perc: int = float(p_new_value) / EMC_Avatar.MAX_VITALS * 100 #float() Casting wichtig!
	$HBoxContainer5/VBoxContainer2/HBoxContainer3/HealthBar.set_value_no_signal(perc)

