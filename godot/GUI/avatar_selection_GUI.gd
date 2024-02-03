extends EMC_GUI
class_name EMC_AvatarSelectionGUI

const SPRITE_W01 = "W01"
const SPRITE_W02 = "W02"
const SPRITE_W03 = "W03"
const SPRITE_W04 = "W04"
const SPRITE_W05 = "W05"
const SPRITE_W06 = "W06"
const SPRITE_NB01 = "NB01"
const SPRITE_NB02 = "NB02"
const SPRITE_NB03 = "NB03"
const SPRITE_NB04 = "NB04"
const SPRITE_NB05 = "NB05"
const SPRITE_NB06 = "NB06"
const SPRITE_M01 = "M01"
const SPRITE_M02 = "M02"
const SPRITE_M03 = "M03"
const SPRITE_M04 = "M04"
const SPRITE_M05 = "M05"
const SPRITE_M06 = "M06"

var _settingGUI: EMC_Settings

func open(p_settingGUI: EMC_Settings) -> void:
	_settingGUI = p_settingGUI
	$CanvasLayer.show()
	$CanvasModulate.show()
	show()
	opened.emit()


func close() -> void:
	$CanvasLayer.hide()
	$CanvasModulate.hide()
	hide()
	closed.emit()


func _ready() -> void:
	close()


func _on_w_01_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W01)


func _on_nb_01_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB01)


func _on_m_01_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M01)


func _on_w_02_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W02)


func _on_nb_02_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB02)


func _on_m_02_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M02)


func _on_w_03_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W03)


func _on_nb_03_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB03)


func _on_m_03_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M03)


func _on_w_04_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W04)


func _on_nb_04_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB04)


func _on_m_04_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M05)


func _on_w_05_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W05)


func _on_nb_05_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB05)


func _on_m_05_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M05)


func _on_w_06_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W06)


func _on_nb_06_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB06)


func _on_m_06_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M06)
