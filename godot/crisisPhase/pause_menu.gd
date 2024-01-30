extends EMC_GUI

@onready var _settings : EMC_GUI = $CanvasLayer_unaffectedByCM/Settings
@onready var canvas_modulate := $CanvasModulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	_settings.close()
	_settings.closed.connect(open)


func open() -> void:
	get_tree().paused = true
	show()
	$CanvasLayer_unaffectedByCM.show()
	canvas_modulate.show()
	opened.emit()


func close() -> void:
	get_tree().paused = false
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	canvas_modulate.hide()
	closed.emit()


func _on_resume_btn_pressed() -> void:
	close()


func _on_settings_pressed() -> void:
	_settings.open()
	$CanvasLayer_unaffectedByCM.hide()


## TODO
func _on_cancel_curr_crisis_pressed() -> void:
	Global.reset_state()
	get_tree().paused = false
	Global.goto_scene(Global.PREPARE_PHASE_SCENE)


## TODO
func _on_save_and_quit_pressed() -> void:
	await Global.save_game(true)
	get_tree().quit()
