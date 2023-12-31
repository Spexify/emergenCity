extends TextureRect
class_name EMC_CityMap

var _tooltip_GUI: EMC_TooltipGUI
var _stage_mngr: EMC_StageMngr
var _day_mngr: EMC_DayMngr
#var _pin_pos_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func setup(p_day_mngr: EMC_DayMngr, p_stage_mngr: EMC_StageMngr, p_tooltip_GUI: EMC_TooltipGUI) -> void:
	_day_mngr = p_day_mngr
	_stage_mngr = p_stage_mngr
	_tooltip_GUI = p_tooltip_GUI


func open() -> void:
	get_tree().paused = true
	
	#Setup Current-Location-Pin
	var curr_stage_name := _stage_mngr.get_curr_stage_name()
	match curr_stage_name:
		EMC_StageMngr.STAGENAME_HOME:
			$Pin.position = Vector2i(150, 230)
		EMC_StageMngr.STAGENAME_MARKET:
			$Pin.position = Vector2i(103, 460)
		_: push_error("CityMap-Pin kennt momentane Stage nicht!")
	#_pin_pos_tween = get_tree().create_tween()
	#_pin_pos_tween.tween_property($Pin, "position", $Pin.position - Vector2(0, 15), 0.5).set_trans(Tween.TRANS_CUBIC)
	#_pin_pos_tween.set_loops() #no arguments = infinite
	$Pin/AnimationPlayer.play("pin_animation")
	show()


#func _process(delta: float) -> void:
	#if _pin_pos_tween != null:
		#print(_pin_pos_tween.is_running())


func close() -> void:
	get_tree().paused = false
	$Pin/AnimationPlayer.stop()
	hide()


func _on_back_btn_pressed() -> void:
	close()


func _on_home_btn_pressed() -> void:
	_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_HOME)


func _on_marketplace_btn_pressed() -> void:
	_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_MARKET)


func _on_elias_flat_btn_pressed() -> void:
	_tooltip_GUI.open("Eljas Wohnung ist noch nicht implementiert!")


func _on_public_building_btn_pressed() -> void:
	_tooltip_GUI.open("Öffentliches Gebäude ist noch nicht implementiert!")


func _on_julias_house_btn_pressed() -> void:
	_tooltip_GUI.open("Julias Zuhause ist noch nicht implementiert!")


func _on_complex_btn_pressed() -> void:
	_tooltip_GUI.open("Apartment-Komplex (Agathe, Mert, Veronika, Kris) ist noch nicht implementiert!")


func _on_gardenhouse_btn_pressed() -> void:
	_tooltip_GUI.open("Gerhards Gartenhaus ist noch nicht implementiert!")


func _on_villa_btn_pressed() -> void:
	_tooltip_GUI.open("Petro & Irenas Villa ist noch nicht implementiert!")


func _on_nature_btn_pressed() -> void:
	_tooltip_GUI.open("Hain ist noch nicht implementiert!")


func _on_change_stage_gui_closed() -> void:
	$MarketplaceBtn.show() #MRM: Bugfix: Sonst überlappt der Button den BestätigenButton der ChangeStage GUI


func _on_change_stage_gui_opened() -> void:
	$MarketplaceBtn.hide()


func _on_change_stage_gui_stayed_on_same_stage() -> void:
	close()
