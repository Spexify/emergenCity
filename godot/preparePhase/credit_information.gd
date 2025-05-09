extends Control

@onready var license_information := $CanvasLayer_unaffectedByCM/LicenseInformation
@onready var control := $CanvasLayer_unaffectedByCM/Control

func _ready() -> void:
	license_information.closed.connect(open)

func open() -> void:
	show()
	control.show()

func close() -> void:
	hide()

func _on_texture_button_pressed() -> void:
	close()
	Global.goto_scene("res://preparePhase/main_menu.tscn")

func _on_meta_clicked(meta : Variant) -> void:
	var font_name : String = meta as String
	if font_name == null:
		return
		
	license_information.open(font_name)
	control.hide()
