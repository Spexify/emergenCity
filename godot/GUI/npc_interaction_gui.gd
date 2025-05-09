extends EMC_GUI
class_name EMC_Interaction_GUI

const UX_BUTTON := preload("res://util/UX_button.tscn")

@onready var portrait : TextureRect = $Portrait
@onready var buttons : VBoxContainer = $Buttons
@onready var descr : RichTextLabel = $Panel/Descr

func open(npc : EMC_NPC) -> void:
	var npc_descr: EMC_NPC_Descr = npc.get_comp(EMC_NPC_Descr)
	
	descr.set_text(npc_descr.get_desc())
	
	portrait.set_texture(npc_descr.get_portrait())
	
	for child in buttons.get_children():
		buttons.remove_child(child)
		
	var npc_interactions: EMC_NPC_Interaction = npc.get_comp(EMC_NPC_Interaction)
	var interaction: Dictionary = npc_interactions.get_interactions()
	
	for option : String in interaction:
		var button : Button = UX_BUTTON.instantiate()
		button.set_text(option)
		button.set_theme_type_variation("BlueButton")
		button.pressed.connect(_on_option_pressed.bind(interaction[option]))
		
		buttons.add_child(button)
	
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)

func _on_option_pressed(option : EMC_NPC_Interaction_Option) -> void:
	close()
	option.run()
