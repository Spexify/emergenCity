extends TextureRect
class_name EMC_CityMap

signal opened
signal closed

@onready var _curr_pos_pin := $CurrPosPin
@onready var _home_pin := $HomePin

var _crisis_phase: EMC_CrisisPhase
var _tooltip_GUI: EMC_TooltipGUI
var _stage_mngr: EMC_StageMngr
var _day_mngr: EMC_DayMngr


########################################## PUBLIC METHODS ##########################################
func setup(p_crisis_phase: EMC_CrisisPhase, p_day_mngr: EMC_DayMngr, p_stage_mngr: EMC_StageMngr, p_tooltip_GUI: EMC_TooltipGUI, \
	p_cs_GUI: EMC_ChangeStageGUI) -> void:
	_crisis_phase = p_crisis_phase
	_day_mngr = p_day_mngr
	_stage_mngr = p_stage_mngr
	_tooltip_GUI = p_tooltip_GUI
	p_cs_GUI.stayed_on_same_stage.connect(_on_change_stage_gui_stayed_on_same_stage)
	$DoorbellsGUI.setup(p_stage_mngr)


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
			_curr_pos_pin.position = Vector2i(206, 920)
		_: push_error("CityMap-Pin kennt momentane Stage nicht!")
	#_pin_pos_tween = get_tree().create_tween()
	#_pin_pos_tween.tween_property($Pin, "position", $Pin.position - Vector2(0, 15), 0.5).set_trans(Tween.TRANS_CUBIC)
	#_pin_pos_tween.set_loops() #no arguments = infinite
	_curr_pos_pin.get_node("AnimationPlayer").play("pin_animation")
	_home_pin.get_node("AnimationPlayer").play("pin_animation")
	show()
	_crisis_phase.add_back_button(_on_back_btn_pressed)
	opened.emit()


func close() -> void:
	_stage_mngr.get_tree().paused = false
	_curr_pos_pin.get_node("AnimationPlayer").stop()
	_home_pin.get_node("AnimationPlayer").stop()
	hide()
	$DoorbellsGUI.hide()
	_crisis_phase.remove_back_button()
	closed.emit()


########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


#func _process(delta: float) -> void:
	#if _pin_pos_tween != null:
		#print(_pin_pos_tween.is_running())


func _on_back_btn_pressed() -> void:
	close()


func _on_home_btn_pressed() -> void:
	_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_HOME)


func _on_marketplace_btn_pressed() -> void:
	if OverworldStatesMngr.get_isolation_state() == OverworldStatesMngr.IsolationState.LIMITED_ACCESS_MARKET:
		_tooltip_GUI.open("Der Marktplatz ist nicht betretbar!")
	else: 
		_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_MARKET)


func _on_elias_flat_btn_pressed() -> void:
	_tooltip_GUI.open("Eljas Wohnung ist noch nicht implementiert!")


func _on_townhall_btn_pressed() -> void:
	_tooltip_GUI.open("Rathaus ist noch nicht implementiert!")


func _on_julias_house_btn_pressed() -> void:
	_tooltip_GUI.open("Julias Zuhause ist noch nicht implementiert!")


func _on_complex_btn_pressed() -> void:
	$DoorbellsGUI.open()


func _on_gardenhouse_btn_pressed() -> void:
	_tooltip_GUI.open("Gerhards Gartenhaus ist noch nicht implementiert!")


func _on_villa_btn_pressed() -> void:
	_tooltip_GUI.open("Petro & Irenas Villa ist noch nicht implementiert!")


func _on_nature_btn_pressed() -> void:
	_tooltip_GUI.open("Lichtung ist noch nicht implementiert!")


func _on_change_stage_gui_stayed_on_same_stage() -> void:
	close()