extends Control

signal opened
signal closed

#const SLOT_CNT : int = 30
var m_slotScene : PackedScene = preload("res://items/inventory_slot.tscn")
var m_slotCnt : int

## Constructor
## Takes in a count of how many slot the inventory is supposed to have.
func _init(p_slotCnt : int = 30):
	m_slotCnt = p_slotCnt

# Called when the node enters the scene tree for the first time.
func _ready():
	var gridContainer : GridContainer = get_node("Background/VBoxContainer/GridContainer")
	
	for n in m_slotCnt:
		var newSlot = m_slotScene.instantiate()
		gridContainer.add_child(newSlot)
	
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _unhandled_input(event):
	if ((event is InputEventMouseButton && event.pressed == true)
	or (event is InputEventScreenTouch)):
		if visible == true:
			close()
			get_viewport().set_input_as_handled()


func toggle() -> void:
	if visible == false:
		open()
	else:
		close()


func open():
	visible = true
	opened.emit()

func close():
	visible = false
	closed.emit()


func _on_btn_backpack_released():
	get_viewport().set_input_as_handled() #needed, otherwhise it directly closes the window again
	open()
