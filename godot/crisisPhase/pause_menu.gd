extends EMC_GUI

@onready var _settings := $CanvasLayer_unaffectedByCM/Settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	_settings.hide()


func open() -> void:
	get_tree().paused = true
	show()
	$CanvasLayer_unaffectedByCM.show()
	opened.emit()


func close() -> void:
	get_tree().paused = false
	hide()
	$CanvasLayer_unaffectedByCM.hide()
	closed.emit()


func _on_resume_btn_pressed() -> void:
	close()


func _on_settings_pressed() -> void:
	_settings.show()
	#MRM: Don't get why this is necessary, but it won't open up reliably without this:
	for child: Node in _settings.get_children():
		child.show()


## TODO
func _on_cancel_curr_crisis_pressed() -> void:
	Global.reset_state()
	get_tree().paused = false
	Global.goto_scene(Global.PREPARE_PHASE_SCENE)


## TODO
func _on_save_and_quit_pressed() -> void:
	await Global.save_game(true)
	get_tree().quit()
