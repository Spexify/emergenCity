extends Control

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
