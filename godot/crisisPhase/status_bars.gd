extends Control

@onready var _smokeVFX_nutrition := $HBC/VBoxContainer/NutritionCont/ContainerNutrition/SmokeVFX
@onready var _smokeVFX_hydration := $HBC/VBoxContainer/HydrationCont/ContainerHydration/SmokeVFX
@onready var _smokeVFX_health := $HBC/VBoxContainer2/HealthCont/ContainerHealth/SmokeVFX
@onready var _smokeVFX_happiness := $HBC/VBoxContainer2/HappinessCont/ContainerHappiness/SmokeVFX

@onready var nutrition_bar : ProgressBar = $HBC/VBoxContainer/NutritionCont/NutritionBar
@onready var calories_label : RichTextLabel = $HBC/VBoxContainer/NutritionCont/NutritionBar/CaloriesLabel
@onready var nutrition_icon : Sprite2D = $HBC/VBoxContainer/NutritionCont/ContainerNutrition/NutritionIcon

@onready var hydration_bar : ProgressBar = $HBC/VBoxContainer/HydrationCont/HydrationBar
@onready var milliliters_label : RichTextLabel = $HBC/VBoxContainer/HydrationCont/HydrationBar/MillilitersLabel
@onready var hydration_icon : Sprite2D = $HBC/VBoxContainer/HydrationCont/ContainerHydration/HydrationIcon

@onready var health_bar : ProgressBar = $HBC/VBoxContainer2/HealthCont/HealthBar
@onready var health_label : RichTextLabel = $HBC/VBoxContainer2/HealthCont/HealthBar/HealthLabel
@onready var health_icon : Sprite2D = $HBC/VBoxContainer2/HealthCont/ContainerHealth/HealthIcon

@onready var happiness_bar : ProgressBar = $HBC/VBoxContainer2/HappinessCont/HappinessBar
@onready var happiness_label : RichTextLabel = $HBC/VBoxContainer2/HappinessCont/HappinessBar/HappinessLabel
@onready var happiness_icon : Sprite2D = $HBC/VBoxContainer2/HappinessCont/ContainerHappiness/HappinessIcon

var _gui_mngr : EMC_GUIMngr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sb := StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color("ff0000")

func setup(p_gui_mngr : EMC_GUIMngr) -> void:
	_gui_mngr = p_gui_mngr

func _on_avatar_nutrition_updated(p_new_value: int) -> void:
	await ready
	
	var perc: int = float(p_new_value)  #float() Casting wichtig!
	nutrition_bar.max_value = EMC_Avatar.MAX_VITALS_NUTRITION*EMC_Avatar.UNIT_FACTOR_NUTRITION
	calories_label.text = "[color=white][center]" + str(perc) +" kcal[/center][/color]"
	nutrition_bar.set_value_no_signal(perc)
	#Play VFX
	if _smokeVFX_nutrition != null:
		#_smokeVFX_nutrition.process_material.color = EMC_Palette.LIGHT_GREEN
		_smokeVFX_nutrition.position = nutrition_icon.global_position
		_smokeVFX_nutrition.emitting = true


func _on_avatar_hydration_updated(p_new_value: int) -> void:
	await ready
	
	var perc: int = float(p_new_value)  #float() Casting wichtig!
	hydration_bar.max_value = EMC_Avatar.MAX_VITALS_HYDRATION*EMC_Avatar.UNIT_FACTOR_HYDRATION
	milliliters_label.text = "[color=white][center]" + str(perc) +" ml[/center][/color]"
	hydration_bar.set_value_no_signal(perc)
	#Play VFX
	if _smokeVFX_hydration != null:
		#_smokeVFX_hydration.process_material.color = EMC_Palette.LIGHT_BLUE
		_smokeVFX_hydration.position = hydration_icon.global_position
		_smokeVFX_hydration.emitting = true

func _on_avatar_health_updated(p_new_value: int) -> void:
	await ready
	
	var perc: int = float(p_new_value)  #float() Casting wichtig!
	health_bar.max_value = EMC_Avatar.MAX_VITALS_HEALTH*EMC_Avatar.UNIT_FACTOR_HEALTH
	health_label.text = "[color=white][center]" + str(perc) +" %[/center][/color]"
	health_bar.set_value_no_signal(perc)
	#Play VFX
	if _smokeVFX_health != null:
		#_smokeVFX_health.process_material.color = EMC_Palette.LIGHT_RED
		_smokeVFX_health.position = health_icon.global_position
		_smokeVFX_health.emitting = true


func _on_avatar_happiness_updated(p_new_value: int) -> void:
	await ready
	
	var perc: int = float(p_new_value) #float() Casting wichtig!
	happiness_bar.max_value = EMC_Avatar.MAX_VITALS_HAPPINESS * EMC_Avatar.UNIT_FACTOR_HAPPINESS
	happiness_label.text = "[color=white][center]" + str(perc) +" %[/center][/color]"
	happiness_bar.set_value_no_signal(perc)
	#Play VFX
	if _smokeVFX_happiness != null:
		#_smokeVFX_happiness.process_material.color = EMC_Palette.LIGHT_YELLOW
		_smokeVFX_happiness.position = happiness_icon.global_position
		_smokeVFX_happiness.emitting = true

func _on_nutrition_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("Tooltip", ["Diese Leiste stellt deinen Hunger dar."])

func _on_hydration_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("Tooltip", ["Diese Leiste stellt deinen Durst dar."])

func _on_health_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("Tooltip", ["Diese Leiste stellt deine Gesundheit & Hygiene dar."])

func _on_happiness_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("Tooltip", ["Diese Leiste stellt deine Glücklichkeit dar."])
