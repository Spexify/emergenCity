extends EMC_ActionGUI
class_name EMC_FilterWaterGUI

var _inventory : EMC_Inventory
var _chlor_tabs : EMC_Item

func setup(_p_inventory : EMC_Inventory) -> void:
	_inventory = _p_inventory
	_chlor_tabs = _inventory.get_item_of_ID(13)

func open() -> void:
	visible = true
	$SFX/OpenGUISFX.play()
	$DirtyWaterAvailable.visible = true
	$DirtyWaterFiltered.visible = false
	opened.emit()

## closes summary end of day GUI/makes invisible
func close() -> void:
	$SFX/OpenGUISFX.play()
	visible = false
	closed.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_filter_pressed() -> void:
	$SFX/ButtonSFX.play()
	var _chlor_tabs_uses := _chlor_tabs.get_comp(EMC_IC_Uses)
	_chlor_tabs_uses.item_used(1)
	if  _chlor_tabs_uses.get_uses_left() == 0:
		_inventory.remove_item(13,1)
	_inventory.remove_item(2,1)
	_inventory.add_new_item(1)
	$DirtyWaterAvailable.visible = false
	$DirtyWaterFiltered.visible = true


func _on_cancel_pressed() -> void: 
	$SFX/ButtonSFX.play()
	close()
