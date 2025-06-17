extends CharacterBody2D
class_name EMC_NPC

class EMC_NPC_Comp extends Node:
	pass 

signal clicked(p_NPC: EMC_NPC)

const TIME := ["morning", "noon", "evening"]

@export var comps: Array[EMC_NPC_Comp]

@onready var hitbox : CollisionShape2D = $CollisionCircle
@onready var prompt_button : TextureButton = $DialogueHitbox

var _gui_mngr : EMC_GUIMngr
var _stage_mngr : EMC_StageMngr
var _day_mngr: EMC_DayMngr

var _comps: Array[Variant]

func setup(p_gui_mngr : EMC_GUIMngr, p_stage_mngr: EMC_StageMngr, p_day_mngr: EMC_DayMngr) -> void:
	_gui_mngr = p_gui_mngr
	_stage_mngr = p_stage_mngr
	_day_mngr = p_day_mngr

func _ready() -> void:
	$AnimationPlayer.play("idle")
	
	prompt_button.pressed.connect(_on_button_pressed)

func add_comp(comp: Variant) -> void:
	_comps.append(comp)

func get_comp(comp_class: Variant) -> Variant:
	for comp: Variant in _comps:
		if  is_instance_of(comp, comp_class):
			return comp
	return null

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

func _on_button_pressed() -> void:
	clicked.emit(self)
	
func enable() -> void:
	show()
	hitbox.set_deferred("disabled", false)#
	
func disbale() -> void:
	hide()
	hitbox.set_deferred("disabled", true)

##############################################
