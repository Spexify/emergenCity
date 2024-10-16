extends EMC_ActionGUI

var _overworld_states_mngr_ref : EMC_OverworldStatesMngr
var _inventory_ref : EMC_Inventory


func setup(p_overworld_states_mngr_ref: EMC_OverworldStatesMngr, p_inventory_ref: EMC_Inventory) -> void:
	_overworld_states_mngr_ref = p_overworld_states_mngr_ref
	_inventory_ref = p_inventory_ref
	$PanelContainer/VBoxContainer/PanelContainer/RichTextLabel.text = "In der Regentonne sind " + str(float(_overworld_states_mngr_ref.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser."


func _on_get_water_btn_pressed() -> void:
	SoundMngr.play_sound("water")
	if _overworld_states_mngr_ref.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) > 0:
		if _inventory_ref.add_new_item(EMC_Item.IDs.WATER_DIRTY):
			_overworld_states_mngr_ref.set_furniture_state(
				EMC_Upgrade.IDs.RAINWATER_BARREL,
				_overworld_states_mngr_ref.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) - 1
			)
			$PanelContainer/VBoxContainer/PanelContainer/RichTextLabel.text = "In der Regentonne sind " + str(float(_overworld_states_mngr_ref.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser."


func _on_done_btn_pressed() -> void:
	hide() # Replace with function body.
	closed.emit(self)


func open(p_action: EMC_Action) -> void:
	$PanelContainer/VBoxContainer/PanelContainer/RichTextLabel.text = "In der Regentonne sind " + str(float(_overworld_states_mngr_ref.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser."
	#$SFX/OpenGUISFX.play()
	show()
	opened.emit()
