extends Control

@onready var _smokeVFX_nutrition := $HBC/VBoxContainer/NutritionCont/ContainerNutrition/SmokeVFX
@onready var _smokeVFX_hydration := $HBC/VBoxContainer/HydrationCont/ContainerHydration/SmokeVFX
@onready var _smokeVFX_health := $HBC/VBoxContainer2/HealthCont/ContainerHealth/SmokeVFX
@onready var _smokeVFX_happiness := $HBC/VBoxContainer2/HappinessCont/ContainerHappiness/SmokeVFX

@onready var calories_label : RichTextLabel = $HBC/VBoxContainer/NutritionCont/CaloriesLabel
@onready var nutrition_icon : Sprite2D = $HBC/VBoxContainer/NutritionCont/ContainerNutrition/NutritionIcon
@onready var nutrition_quad : MeshInstance2D = $HBC/VBoxContainer/NutritionCont/NutritionQuad

@onready var milliliters_label : RichTextLabel = $HBC/VBoxContainer/HydrationCont/MillilitersLabel
@onready var hydration_icon : Sprite2D = $HBC/VBoxContainer/HydrationCont/ContainerHydration/HydrationIcon
@onready var hydration_quad : MeshInstance2D = $HBC/VBoxContainer/HydrationCont/HydrationQuad

@onready var health_label : RichTextLabel = $HBC/VBoxContainer2/HealthCont/HealthLabel
@onready var health_icon : Sprite2D = $HBC/VBoxContainer2/HealthCont/ContainerHealth/HealthIcon
@onready var health_quad : MeshInstance2D = $HBC/VBoxContainer2/HealthCont/HealthQuad

@onready var happiness_label : RichTextLabel = $HBC/VBoxContainer2/HappinessCont/HappinessLabel
@onready var happiness_icon : Sprite2D = $HBC/VBoxContainer2/HappinessCont/ContainerHappiness/HappinessIcon
@onready var happiness_quad : MeshInstance2D = $HBC/VBoxContainer2/HappinessCont/HappinessQuad

var _gui_mngr : EMC_GUIMngr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sb := StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	sb.bg_color = Color("ff0000")

func setup(p_gui_mngr : EMC_GUIMngr) -> void:
	_gui_mngr = p_gui_mngr

var _percentage_nutrition : float = 0.0
func _on_avatar_nutrition_updated(p_new_value: int) -> void:
	if not is_node_ready():
		return
	
	var percentage: float = float(p_new_value)/float(EMC_Avatar.MAX_VITALS_NUTRITION*EMC_Avatar.UNIT_FACTOR_NUTRITION)
	calories_label.set_text("[color=white][center]" + str(p_new_value) +" kcal[/center][/color]")

	var tween :Tween = get_tree().create_tween()
	tween.tween_method(_set_nutrition_shader, _percentage_nutrition, percentage, 1.0)
	_percentage_nutrition = percentage

	#Play VFX
	_smokeVFX_nutrition.set_emitting(true)

func _set_nutrition_shader(value : float) -> void:
	nutrition_quad.get_material().set_shader_parameter("progress", value);

var _percentage_hydration : float = 0.0
func _on_avatar_hydration_updated(p_new_value: int) -> void:
	if not is_node_ready():
		return
	
	var percentage: float = float(p_new_value)/float(EMC_Avatar.MAX_VITALS_HYDRATION*EMC_Avatar.UNIT_FACTOR_HYDRATION)
	milliliters_label.set_text("[color=white][center]" + str(p_new_value) +" ml[/center][/color]")
	
	var tween :Tween = get_tree().create_tween()
	tween.tween_method(_set_hydration_shader, _percentage_hydration, percentage, 1.0)
	_percentage_hydration = percentage
	
	#Play VFX
	_smokeVFX_hydration.set_emitting(true)
	
func _set_hydration_shader(value : float) -> void:
	hydration_quad.get_material().set_shader_parameter("progress", value);

var _percentage_health : float = 0.0
func _on_avatar_health_updated(p_new_value: int) -> void:
	if not is_node_ready():
		return
	
	var percentage: float = float(p_new_value)/float(EMC_Avatar.MAX_VITALS_HEALTH*EMC_Avatar.UNIT_FACTOR_HEALTH)
	health_label.set_text("[color=white][center]" + str(p_new_value) +" %[/center][/color]")
	
	var tween : Tween = Global.get_tree().create_tween()
	tween.tween_method(_set_health_shader, _percentage_health, percentage, 1.0)
	_percentage_health = percentage
	
	#Play VFX
	_smokeVFX_health.set_emitting(true)

func _set_health_shader(value : float) -> void:
	health_quad.get_material().set_shader_parameter("progress", value);

var _percentage_happiness : float = 0.0
func _on_avatar_happiness_updated(p_new_value: int) -> void:
	if not is_node_ready():
		return
	
	var percentage: float = float(p_new_value)/float(EMC_Avatar.MAX_VITALS_HAPPINESS * EMC_Avatar.UNIT_FACTOR_HAPPINESS)
	happiness_label.set_text("[color=white][center]" + str(p_new_value) +" %[/center][/color]")
	
	var tween :Tween = get_tree().create_tween()
	tween.tween_method(_set_happpiness_shader, _percentage_happiness, percentage, 1.0)
	_percentage_happiness = percentage
	
	#Play VFX
	_smokeVFX_happiness.set_emitting(true)
	
func _set_happpiness_shader(value : float) -> void:
	happiness_quad.get_material().set_shader_parameter("progress", value);

func _on_nutrition_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deinen Hunger dar."])

func _on_hydration_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deinen Durst dar."])

func _on_health_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deine Gesundheit & Hygiene dar."])

func _on_happiness_cont_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.is_pressed():
		_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deine Glücklichkeit dar."])
