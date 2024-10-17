extends EMC_ActionGUI
class_name EMC_SinkGUI

@onready var text : RichTextLabel = $VBoxContainer/PanelContainer/Text
@onready var fill_reservoir : Button = $VBoxContainer/HBoxContainer/FillReservoir
@onready var confirm_btn : Button = $VBoxContainer/HBoxContainer/ConfirmBtn

var _inventory: EMC_Inventory

########################################## PUBLIC METHODS ##########################################
func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory


## Method that should be overwritten in each class that implements [EMC_ActionGUI]:
func open(p_action: EMC_Action) -> void:
	_action = p_action
	
	if OverworldStatesMngr.get_water_state() == OverworldStatesMngr.WaterState.CLEAN:
		if Global.has_upgrade(EMC_Upgrade.IDs.WATER_RESERVOIR):
			text.set_text("Willst du Wasser in eine Flasche oder ins Reservoir abfüllen?")
			confirm_btn.set_text("Flasche")
			fill_reservoir.show()
		else:
			text.set_text("Willst du Wasser in eine Flasche abfüllen?")
			confirm_btn.set_text("Bestätigen")
			fill_reservoir.hide()
	else:
		text.set_text("Das Wasser ist verdreckt. Sicher das du es in eine Flasche abfüllen willst?.")
		confirm_btn.set_text("Bestätigen")
		fill_reservoir.hide()
	
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	hide()


func _on_confirm_btn_pressed() -> void:
	#if OverworldStatesMngr.get_water_state() == OverworldStatesMngr.WaterState.DIRTY:
		#_action.add_consequence("add_health", -1)
	#_action.add_consequence("add_hydration", 1)
	
	var item : String = "WATER" if OverworldStatesMngr.get_water_state() == OverworldStatesMngr.WaterState.CLEAN else "WATER_DIRTY"
	_action.add_consequence("add_item_question", [item, {
					"question": "Du hast %s abgefüllt. Möchtest du es jetzt trinken?",
					"answere": "Trinken"
				}])
	
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = _action.play_sound()
	##Don't wait, because it causes problems because you can still click somewherelse
	##while the SFX is playing (Made SoundMngr process always)
	#if wait != null:
		#await wait.finished 
	
	_action.silent_executed.emit(_action)
	close()

func _on_confirm_btn_with_soap_pressed() -> void:
	_action.add_consequence("fill_reservoir", 0)
	_action.executed.emit(_action)
	close()

func _on_back_btn_pressed() -> void:
	close()
