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

#FYI: erbt "name" Attribut von Node
var _ID: IDs = IDs.DUMMY
var _descr: String = "<No Descr>"
var _comps: Array[EMC_ItemComponent]


#------------------------------------------ PUBLIC METHODS -----------------------------------------
##Objekt-Attribute initialisieren
func setup(ID: int) -> void:
	_ID = ID
	
	
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


#FYI: erbt "get_name()" Attribut von Node

##Getter für _ID
func get_ID() -> IDs:
	return _ID

##Getter für _descr
func get_descr() -> String:
	return _descr

##Getter für _descr
func get_comps() -> Array[EMC_ItemComponent]:
	return _comps

#----------------------------------------- PRIVATE METHODS -----------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = _ID
#	add_to_group("items") #Über den Editor realisiert...


func _on_gui_input(event: InputEvent) -> void:
	if ((event is InputEventMouseButton && event.pressed == true)
	or (event is InputEventScreenTouch)):
		clicked.emit(self)
		#Ruft _on_clicked(self) für alle Instanzen an Items (s. Gruppe "items") auf:
		get_tree().call_group("items", "_on_clicked", self) 


func _on_clicked(sender: EMC_Item) -> void:
	if sender == self:
		self.modulate = Color(0.4, 0.4, 0.4)
	else:
		self.modulate = Color(1, 1, 1)
