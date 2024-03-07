extends EMC_ActionGUI
class_name EMC_CityMap

#signal opened
#signal closed

@onready var _curr_pos_pin := $CurrPosPin
@onready var _home_pin := $HomePin
@onready var _opt_event_pin_template := $OptEventPin_Template
@onready var _opt_event_pins := $OptEventPins

var _crisis_phase: EMC_CrisisPhase
var _tooltip_GUI: EMC_TooltipGUI
var _stage_mngr: EMC_StageMngr
var _day_mngr: EMC_DayMngr
var _opt_event_mngr: EMC_OptionalEventMngr


########################################## PUBLIC METHODS ##########################################
func setup(p_crisis_phase: EMC_CrisisPhase, p_day_mngr: EMC_DayMngr, p_stage_mngr: EMC_StageMngr, p_tooltip_GUI: EMC_TooltipGUI, \
	p_cs_GUI: EMC_ChangeStageGUI, p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_crisis_phase = p_crisis_phase
	_day_mngr = p_day_mngr
	_stage_mngr = p_stage_mngr
	_tooltip_GUI = p_tooltip_GUI
	p_cs_GUI.stayed_on_same_stage.connect(_on_change_stage_gui_stayed_on_same_stage)
	_opt_event_mngr = p_opt_event_mngr
	$DoorbellsGUI.setup(p_stage_mngr)


## The inherited ActionGUI-Method.
## We don't use the action in this case
func show_gui(p_action : EMC_Action) -> void:
	open()


func open() -> void:
	get_tree().paused = true #StageMngr necessary?? Tried to fix bug, but didn't work
	_home_pin.show()
	
	#Setup Current-Location-Pin
	var curr_stage_name := _stage_mngr.get_curr_stage_name()
	match curr_stage_name:
		EMC_StageMngr.STAGENAME_HOME:
			_curr_pos_pin.position = Vector2i(300, 460)
			_home_pin.hide()
		EMC_StageMngr.STAGENAME_MARKET:
			_curr_pos_pin.position = _determine_pin_position($MarketBtn)
		EMC_StageMngr.STAGENAME_TOWNHALL:
			_curr_pos_pin.position = _determine_pin_position($TownhallBtn)
		EMC_StageMngr.STAGENAME_PARK:
			_curr_pos_pin.position = _determine_pin_position($ParkBtn)
		EMC_StageMngr.STAGENAME_GARDENHOUSE:
			_curr_pos_pin.position = _determine_pin_position($GardenhouseBtn)
		EMC_StageMngr.STAGENAME_ROWHOUSE:
			_curr_pos_pin.position = _determine_pin_position($RowhouseBtn)
		EMC_StageMngr.STAGENAME_MANSION:
			_curr_pos_pin.position = _determine_pin_position($MansionBtn)
		EMC_StageMngr.STAGENAME_PENTHOUSE:
			_curr_pos_pin.position = _determine_pin_position($PenthouseBtn)
		_: #You have to be on an extended STAGE of the apartment complex
			_curr_pos_pin.position = _determine_pin_position($ComplexBtn)
	
	#Create an event pin for every stage that a NPC spawns in for every known event
	for known_event: EMC_OptionalEventMngr.Event in _opt_event_mngr.get_known_active_events():
		var spawn_NPCs_arr := known_event.spawn_NPCs_arr
		if spawn_NPCs_arr != null && !spawn_NPCs_arr.is_empty():
			for spawn_NPCs in spawn_NPCs_arr:
				var new_event_pin := _opt_event_pin_template.duplicate()
				_opt_event_pins.add_child(new_event_pin)
				new_event_pin.get_node("AnimationPlayer").play("pin_animation")
				#Try to determine the button belonging to the stage
				var button_node: TextureButton
				if spawn_NPCs.stage_name.contains("apartment_"):
					button_node = $ComplexBtn
				else:
					button_node = get_node(spawn_NPCs.stage_name.capitalize() + "Btn")
				
				if button_node != null:
					new_event_pin.position = _determine_pin_position(button_node)
					new_event_pin.show()
	
	#_pin_pos_tween = get_tree().create_tween()
	#_pin_pos_tween.tween_property($Pin, "position", $Pin.position - Vector2(0, 15), 0.5).set_trans(Tween.TRANS_CUBIC)
	#_pin_pos_tween.set_loops() #no arguments = infinite
	_curr_pos_pin.get_node("AnimationPlayer").play("pin_animation")
	_home_pin.get_node("AnimationPlayer").play("pin_animation")
	show()
	_crisis_phase.add_back_button(_on_back_btn_pressed)
	opened.emit()


func close() -> void:
	## Ugly workaround, to hopefully get rid of misterious nullptr bug:
	if _stage_mngr.get_tree() == null:
		return
	_stage_mngr.get_tree().paused = false
	_curr_pos_pin.get_node("AnimationPlayer").stop()
	_home_pin.get_node("AnimationPlayer").stop()
	hide()
	$DoorbellsGUI.hide()
	_crisis_phase.remove_back_button()
	#Remove all opt event pins
	for prev_duplicated_pin in _opt_event_pins.get_children():
		_opt_event_pins.remove_child(prev_duplicated_pin)
	closed.emit()


########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _on_back_btn_pressed() -> void:
	close()


func _on_home_btn_pressed() -> void:
	_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_HOME)


func _on_marketplace_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_MARKET)


func _on_elias_flat_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_PENTHOUSE)


func _on_townhall_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_TOWNHALL)


func _on_julias_house_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_ROWHOUSE)


func _on_complex_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		$DoorbellsGUI.open()


func _on_gardenhouse_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_GARDENHOUSE)


func _on_villa_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_MANSION)


func _on_park_btn_pressed() -> void:
	if _is_not_evening_suggest_home_return():
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_PARK)


func _on_change_stage_gui_stayed_on_same_stage() -> void:
	close()


## Helper method to deduce the position of the pin on the basis of the Button
func _determine_pin_position(p_texture_button: TextureButton) -> Vector2:
	return p_texture_button.position + \
		Vector2(p_texture_button.texture_normal.get_width()/2,
				p_texture_button.texture_normal.get_height()/2 - 50)


func _is_not_evening_suggest_home_return() -> bool:
	if _day_mngr.get_current_day_period() != EMC_DayMngr.DayPeriod.EVENING:
		return true
	else:
		_tooltip_GUI.open("Es ist schon spät, ich sollte nach Hause gehen.")
		return false
