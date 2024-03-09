extends Control

var _tooltip_GUI: EMC_TooltipGUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sb := StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color("ff0000")
	#$VBoxContainer/HBoxContainer2/NutritionBar.add_child(sb)
	#$VBoxContainer/HBoxContainer2/NutritionBar.draw_style_box(sb, Rect2(30,30,100,20))


func setup(p_tooltip_GUI: EMC_TooltipGUI) -> void:
	_tooltip_GUI = p_tooltip_GUI


func _on_avatar_nutrition_updated(p_new_value: int) -> void:
	var perc: int = float(p_new_value)  #float() Casting wichtig!
	$HBC/VBoxContainer/NutritionCont/NutritionBar.max_value = EMC_Avatar.MAX_VITALS_NUTRITION*EMC_Avatar.UNIT_FACTOR_NUTRITION
	$HBC/VBoxContainer/NutritionCont/NutritionBar/CaloriesLabel.text = "[color=white][center]" + str(perc) +" kcal[/center][/color]"
	$HBC/VBoxContainer/NutritionCont/NutritionBar.set_value_no_signal(perc)


func _on_avatar_hydration_updated(p_new_value: int) -> void:
	var perc: int = float(p_new_value)  #float() Casting wichtig!
	$HBC/VBoxContainer/HydrationCont/HydrationBar.max_value = EMC_Avatar.MAX_VITALS_HYDRATION*EMC_Avatar.UNIT_FACTOR_HYDRATION
	$HBC/VBoxContainer/HydrationCont/HydrationBar/MillilitersLabel.text = "[color=white][center]" + str(perc) +" ml[/center][/color]"
	$HBC/VBoxContainer/HydrationCont/HydrationBar.set_value_no_signal(perc)


func _on_avatar_health_updated(p_new_value: int) -> void:
	var perc: int = float(p_new_value)  #float() Casting wichtig!
	$HBC/VBoxContainer2/HealthCont/HealthBar.max_value = EMC_Avatar.MAX_VITALS_HEALTH*EMC_Avatar.UNIT_FACTOR_HEALTH
	$HBC/VBoxContainer2/HealthCont/HealthBar/HealthLabel.text = "[color=white][center]" + str(perc) +" %[/center][/color]"
	$HBC/VBoxContainer2/HealthCont/HealthBar.set_value_no_signal(perc)


func _on_avatar_happiness_updated(p_new_value: int) -> void:
	var perc: int = float(p_new_value) #float() Casting wichtig!
	$HBC/VBoxContainer2/HappinessCont/HappinessBar.max_value = EMC_Avatar.MAX_VITALS_HAPPINESS * EMC_Avatar.UNIT_FACTOR_HAPPINESS
	$HBC/VBoxContainer2/HappinessCont/HappinessBar/HappinessLabel.text = "[color=white][center]" + str(perc) +" %[/center][/color]"
	$HBC/VBoxContainer2/HappinessCont/HappinessBar.set_value_no_signal(perc)


func _on_nutrition_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_tooltip_GUI.open("Diese Leiste stellt deinen Hunger dar.")


func _on_hydration_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_tooltip_GUI.open("Diese Leiste stellt deinen Durst dar.")


func _on_health_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_tooltip_GUI.open("Diese Leiste stellt deine Gesundheit & Hygiene dar.")


func _on_happiness_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_tooltip_GUI.open("Diese Leiste stellt deine Glücklichkeit dar.")
