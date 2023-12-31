extends TextureRect
class_name EMC_CityMap

var _tooltip_GUI: EMC_TooltipGUI
#var _stage_mngr: EMC_StageMngr
var _day_mngr: EMC_DayMngr

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func setup(p_day_mngr: EMC_DayMngr, p_tooltip_GUI: EMC_TooltipGUI):
	_tooltip_GUI = p_tooltip_GUI
	_day_mngr = p_day_mngr
	#_stage_mngr = p_stage_mngr

func open():
	get_tree().paused = true
	$Pin/AnimationPlayer.play("pin_animation")
	show()


func close():
	get_tree().paused = false
	hide()


func _on_back_btn_pressed():
	close()


func _on_home_btn_pressed():
	_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_HOME)


func _on_marketplace_btn_pressed():
	_day_mngr.on_interacted_with_furniture(EMC_Action.IDs.SC_MARKET)


func _on_elias_flat_btn_pressed():
	_tooltip_GUI.open("Eljas Wohnung ist noch nicht implementiert!")


func _on_public_building_btn_pressed():
	_tooltip_GUI.open("Öffentliches Gebäude ist noch nicht implementiert!")


func _on_julias_house_btn_pressed():
	_tooltip_GUI.open("Julias Zuhause ist noch nicht implementiert!")


func _on_complex_btn_pressed():
	_tooltip_GUI.open("Apartment-Komplex (Agathe, Mert, Veronika, Kris) ist noch nicht implementiert!")


func _on_gardenhouse_btn_pressed():
	_tooltip_GUI.open("Gerhards Gartenhaus ist noch nicht implementiert!")


func _on_villa_btn_pressed():
	_tooltip_GUI.open("Petro & Irenas Villa ist noch nicht implementiert!")


func _on_nature_btn_pressed():
	_tooltip_GUI.open("Hain ist noch nicht implementiert!")


func _on_change_stage_gui_closed():
	$MarketplaceBtn.show() #MRM: Bugfix: Sonst überlappt der Button den BestätigenButton der ChangeStage GUI


func _on_change_stage_gui_opened():
	$MarketplaceBtn.hide()


func _on_change_stage_gui_stayed_on_same_stage():
	close()
