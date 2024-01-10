extends Control
class_name EMC_Item

signal clicked(sender: EMC_Item)

enum IDs{
	DUMMY = 0,
	WATER = 1,
	WATER_DIRTY = 2,
	RAVIOLI_TIN = 3,
	GAS_CARTRIDGE = 4,
	RAVIOLI_MEAL = 5,
}

#FYI: Inherits "name" property from Node
@export var _ID: IDs = IDs.DUMMY
var _descr: String = "<No Descr>"
var _comps: Array[EMC_ItemComponent]


#------------------------------------------ PUBLIC METHODS -----------------------------------------
##Initialize properties
func setup(ID: int) -> void:
	_ID = ID
	$Sprite2D.frame = _ID


	#TODO: Statt case Statement, Infos aus JSON lesen
	match _ID:
		IDs.WATER:
			name = "Wasser"
			_descr = "Sauberes Trinkwasser."
			_comps.push_back(EMC_IC_Drink.new(1))
			_comps.push_back(EMC_IC_Ingredient.new())
		IDs.WATER_DIRTY:
			name = "Dreckiges Wasser"
			_descr = "Nicht die Erstwahl, aber dennoch trinkbar."
			_comps.push_back(EMC_IC_Drink.new(1))
			_comps.push_back(EMC_IC_Ingredient.new())
		IDs.RAVIOLI_TIN:
			name = "Ravioli Konserve"
			_descr = "Kalt genießbar, aber ein Festmahl sieht anders aus.."
			_comps.push_back(EMC_IC_Food.new(8))
			_comps.push_back(EMC_IC_Ingredient.new())
		IDs.GAS_CARTRIDGE:
			name = "Gaskartusche"
			_descr = "Für den Gaskocher."
		IDs.RAVIOLI_MEAL:
			name = "Ravioli Gericht"
			_descr = "Lecker schmecker!"
			_comps.push_back(EMC_IC_Food.new(15))
		_: #default/else
			name = "<No Name>"
			printerr("Item Setup: ID unknown!")


##Getter for _ID
func get_ID() -> IDs:
	return _ID

##Getter for _descr
func get_descr() -> String:
	return _descr

##Getter for _comps
func get_comps() -> Array[EMC_ItemComponent]:
	return _comps

#----------------------------------------- PRIVATE METHODS -----------------------------------------
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = _ID


## TODO
func _on_gui_input(event: InputEvent) -> void:
	if ((event is InputEventMouseButton && event.pressed == true)
	or (event is InputEventScreenTouch)):
		clicked.emit(self)
		#Calls _on_clicked(self) for all instances of signal group "items":
		get_tree().call_group("items", "_on_clicked", self) 


## TODO
func _on_clicked(sender: EMC_Item) -> void:
	const HIGHLIGHTED_COLOR := Color(0.4, 0.4, 0.4)
	const DEFAULT_COLOR := Color(1, 1, 1)
	
	if sender == null:
		printerr("Item._on_clicked(): Sender ist null!")
	elif sender == self:
		self.modulate = HIGHLIGHTED_COLOR
	else:
		self.modulate = DEFAULT_COLOR
