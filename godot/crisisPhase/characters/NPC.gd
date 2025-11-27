extends CharacterBody2D
class_name EMC_NPC_1

signal clicked(p_NPC: EMC_NPC)

const TIME := ["morning", "noon", "evening"]

@onready var hitbox : CollisionShape2D = $CollisionCircle
@onready var prompt_button : TextureButton = $DialogueHitbox

var _gui_mngr : EMC_GUIMngr
var _stage_mngr : EMC_StageMngr
var _day_mngr: EMC_DayMngr
var _crisis_phase: EMC_CrisisPhase

var _comps: Array[Variant]

func setup(p_gui_mngr : EMC_GUIMngr, p_stage_mngr: EMC_StageMngr, p_day_mngr: EMC_DayMngr, p_crisis_phase: EMC_CrisisPhase) -> void:
	_gui_mngr = p_gui_mngr
	_stage_mngr = p_stage_mngr
	_day_mngr = p_day_mngr
	_crisis_phase = p_crisis_phase

func _ready() -> void:
	$AnimationPlayer.play("idle")
	
	prompt_button.pressed.connect(_on_button_pressed)

func add_comp(comp: Variant) -> void:
	_comps.append(comp)

func get_comp(comp_class: Script) -> Variant:
	for comp: Variant in _comps:
		if  is_instance_of(comp, comp_class):
			return comp
	return null
	
func has_comp(comp_class: Variant) -> bool:
	for comp: Variant in _comps:
		if  is_instance_of(comp, comp_class):
			return true
	return false

func get_comp_by_name(comp_name: String) -> Variant:
	for comp: Variant in _comps:
		if comp.get_script().resource_path.get_file().split(".")[0].split("_")[1] == comp_name:
			return comp
	return null
	
func get_gui_mngr() -> EMC_GUIMngr:
	return _gui_mngr
	
func get_stage_mngr() -> EMC_StageMngr:
	return _stage_mngr
	
func get_day_mngr() -> EMC_DayMngr:
	return _day_mngr

func get_act_cond() -> EMC_ActionConstraints:
	return _day_mngr.get_action_constraints()

func get_scoreboard() -> EMC_Scoreboard:
	return _day_mngr._scoreboard

func get_self() -> EMC_NPC_1:
	return self

func _get_sys_by_name(sys_name: String) -> Variant:
	if sys_name == "self":
		return self
	var result := _crisis_phase._get_comp(sys_name)
	if result is EMC_CrisisPhase:
		return self.get_comp_by_name(sys_name)
	return result
	#if sys_name == "self":
		#return self
	#if sys_name == "gui_mngr":
		#return _gui_mngr
	#elif sys_name == "OSM":
		#return OverworldStatesMngr
	#elif sys_name == "ActCond":
		#return self.get_act_cond()
	#elif sys_name == "Score":
		#return self.get_scoreboard()
	#elif sys_name == "stage_mngr":
		#return _stage_mngr
	#return self.get_comp_by_name(sys_name)

func _on_button_pressed() -> void:
	clicked.emit(self)
	
func enable() -> void:
	show()
	hitbox.set_deferred("disabled", false)#
	
func disbale() -> void:
	hide()
	hitbox.set_deferred("disabled", true)

##############################################
