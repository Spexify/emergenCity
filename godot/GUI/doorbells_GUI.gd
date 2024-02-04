extends EMC_GUI

const _DOORBELL_SCN: PackedScene = preload("res://GUI/doorbell.tscn")

@onready var _doorbell_list := $PanelCont/MarginCont/VBC/ButtonBox/ScrollContainer/DoorbellList

func setup(p_stage_mngr: EMC_StageMngr) -> void:
	#await ready
	
	#Load doorbell data
	#TODO: Load from JSON
	var doorbell_agathe := _DOORBELL_SCN.instantiate()
	doorbell_agathe.setup("Agathe", EMC_Action.IDs.SC_APARTMENT_AGATHE)
	doorbell_agathe.rang.connect(p_stage_mngr._on_doorbell_rang)
	_doorbell_list.add_child(doorbell_agathe)
	
	var doorbell_mert := _DOORBELL_SCN.instantiate()
	doorbell_mert.setup("Mert", EMC_Action.IDs.SC_APARTMENT_MERT)
	doorbell_mert.rang.connect(p_stage_mngr._on_doorbell_rang)
	_doorbell_list.add_child(doorbell_mert)
	
	var doorbell_veronika := _DOORBELL_SCN.instantiate()
	doorbell_veronika.setup("Veronika & Kris", EMC_Action.IDs.SC_APARTMENT_CAMPER)
	doorbell_veronika.rang.connect(p_stage_mngr._on_doorbell_rang)
	_doorbell_list.add_child(doorbell_veronika)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()



func open() -> void:
	show()
	#opened.emit()


func close() -> void:
	hide()
	#closed.emit()
