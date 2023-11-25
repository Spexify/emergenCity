extends Control
class_name EC_Item

enum IDs{
	DUMMY = 0,
	WATER = 1,
	WATER_DIRTY = 2,
	RAVIOLI = 3,
	GAS_CARTRIDGE = 4
}

var _ID: int = IDs.DUMMY
var _name: String = "<No Name>"
var _descr: String = "<No Descr>"
#var _comps: <todo> 
var _parent_inventory: EC_Inventory


#------------------------------------------ PUBLIC METHODS -----------------------------------------
##Objekt-Attribute initialisieren
func setup(ID: int, parent_inventory: EC_Inventory) -> void:
	_ID = ID
	_parent_inventory = parent_inventory


	#TODO: Statt case Statement, Infos aus JSON lesen
	match _ID:
		IDs.WATER:
			_name = "Wasser"
			_descr = "Sauberes Trinkwasser."
		IDs.WATER_DIRTY:
			_name = "Dreckiges Wasser"
			_descr = "Nicht die Erstwahl, aber dennoch trinkbar."
		IDs.RAVIOLI:
			_name = "Ravioli"
			_descr = "Lecker schmecker!"
		IDs.GAS_CARTRIDGE:
			_name = "Gas Kartusche"
			_descr = "Für den Gaskocher."


#----------------------------------------- PRIVATE METHODS -----------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.frame = _ID
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_gui_input(event):
	if ((event is InputEventMouseButton && event.pressed == true)
	or (event is InputEventScreenTouch)):
		_parent_inventory.display_info(self)
		#TODO: Set Modulation of Sprite, so it's clear which item was clicked
