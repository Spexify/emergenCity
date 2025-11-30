extends CharacterBody2D
class_name EMC_NPC

signal clicked(p_NPC: EMC_NPC)

@onready var hitbox : CollisionShape2D = $CollisionCircle
@onready var prompt_button : TextureButton = $DialogueHitbox
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var npc_resource: EMC_NPC_Resource

func _ready() -> void:
	$AnimationPlayer.play("idle")
	
	var npc_descr: EMC_NPC_Descr = npc_resource.get_comp(EMC_NPC_Descr)
	
	sprite_2d.set_texture(npc_descr.get_sprite_texture())
	sprite_2d.offset = Vector2(0, -46)
	sprite_2d.hframes = 3
	
	set_name(npc_descr.get_npc_name())
	
	var interaction: EMC_NPC_Interaction = npc_resource.get_comp(EMC_NPC_Interaction)
	if interaction:
		for c : Resource in interaction.get_interactions().values():
			npc_resource.add_comp(c)
	
	var trading: EMC_NPC_Trading = npc_resource.get_comp(EMC_NPC_Trading)
	if trading:
		trading.set_owner(self)
	
	var convers: EMC_NPC_Conversation = npc_resource.get_comp(EMC_NPC_Conversation)
	if convers:
		convers.set_owner(self)
	
	prompt_button.pressed.connect(_on_button_pressed)
	
func change_stage(stage_name: String, spot: EMC_Stage_Spot) -> void:
	var npc_stage: EMC_NPC_Stage = npc_resource.get_comp(EMC_NPC_Stage)
	npc_stage.change_stage(stage_name, spot.name)
	global_position = spot.global_position

func get_current_stage_name() -> String:
	var npc_stage: EMC_NPC_Stage = npc_resource.get_comp(EMC_NPC_Stage)
	return npc_stage.stage_name
	
func get_current_spot() -> String:
	var npc_stage: EMC_NPC_Stage = npc_resource.get_comp(EMC_NPC_Stage)
	return npc_stage.spot

#func _on_stage_changed(stage_name: String) -> void:
	#var npc_stage: EMC_NPC_Stage = npc_resource.get_comp(EMC_NPC_Stage)
	#if stage_name == npc_stage.stage_name:
		#global_position = npc_stage.position
		#enable()
	#else:
		#disable()

func _on_button_pressed() -> void:
	clicked.emit(self)

func enable() -> void:
	show()
	hitbox.set_deferred("disabled", false)
	
func disable() -> void:
	hide()
	hitbox.set_deferred("disabled", true)
