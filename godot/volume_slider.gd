extends HSlider
class_name EMC_VolumeSlider

@export var bus_name: String

var bus_index: int

func _init() -> void:
	set_max(1)
	set_step(0.001)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(bus_index)))
	value_changed.connect(_on_value_changed)
	
func _on_value_changed(value : float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
