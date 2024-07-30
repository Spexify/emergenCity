extends EMC_GUI
class_name EMC_Handy

@onready var apps : GridContainer = $Panel/VBC/Menu/Window/Margin/Apps
@onready var VBC : VBoxContainer = $Panel/VBC
@onready var menu : VBoxContainer = $Panel/VBC/Menu

var active_app : EMC_App

func _ready() -> void:
	for app : EMC_App_Icon in apps.get_children():
		app.open_app.connect(_on_open_app)

func open() -> void:
	self.show()
	if active_app != null:
		active_app.start()
	opened.emit()
	
func close() -> void:
	self.hide()
	closed.emit(self)
	
func restart() -> void:
	if active_app != null:
		active_app.start()

func add_app_icon(app : EMC_App_Icon) -> void:
	apps.add_child(app)
	apps.move_child(app, -2)
	app.open_app.connect(_on_open_app)

func _on_open_app(app_name : String) -> void:
	for child in VBC.get_children():
		if child.name == app_name:
			if active_app == null:
				menu.hide()
			else:
				active_app.hide()
				
			active_app = (child as EMC_App)
			active_app.start()
			return
	printerr("App '" + app_name + "' not found.")
			

func _on_back_button_pressed() -> void:
	close()

func _on_home_button_pressed() -> void:
	if active_app != null:
		active_app.hide()
		active_app = null
	menu.show()
