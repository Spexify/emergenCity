extends EMC_GUI

var _inventory_ref : EMC_Inventory

@onready var rich_text_label :RichTextLabel = $PanelContainer/VBoxContainer/PanelContainer/RichTextLabel


func setup(p_inventory_ref: EMC_Inventory) -> void:
	_inventory_ref = p_inventory_ref
	rich_text_label.text = "In der Regentonne sind " + str(float(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser."

func _on_get_water_btn_pressed() -> void:
	SoundMngr.play_sound("water")
	if OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) > 0:
		if _inventory_ref.add_new_item(EMC_Item.IDs.WATER_DIRTY):
			OverworldStatesMngr.set_furniture_state(
				EMC_Upgrade.IDs.RAINWATER_BARREL,
				OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) - 1
			)
			rich_text_label.text = "In der Regentonne sind " + str(float(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser."

func _on_done_btn_pressed() -> void:
	hide() # Replace with function body.
	closed.emit(self)

func open() -> void:
	rich_text_label.text = "In der Regentonne sind " + str(float(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser."
	#$SFX/OpenGUISFX.play()
	show()
	opened.emit()
