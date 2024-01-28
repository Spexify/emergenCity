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
	UNCOOKED_PASTA = 6,
	COOKED_PASTA = 7,
	SAUCE_JAR = 8,
	PASTA_WITH_SAUCE = 9,
	BREAD = 10,
	JAM = 11,
	BREAD_WITH_JAM = 12,
	CHLOR_TABLETS = 13,
}

#FYI: Inherits "name" property from Node
var _ID: IDs
var _descr: String = "<No Descr>"
var _comps: Array[EMC_ItemComponent]
var _ITEM_SCN : PackedScene = preload("res://items/item.tscn")


########################################## PUBLIC METHODS ##########################################
##Initialize properties
func setup(p_ID: int = IDs.DUMMY) -> void:
	#await ready
	_ID = p_ID
	
	#TODO: Statt case Statement, Infos aus JSON lesen
	match _ID:
		IDs.WATER:
			name = "Wasser"
			_descr = "Sauberes Trinkwasser."
			_comps.push_back(EMC_IC_Drink.new(1))
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(10))
		IDs.WATER_DIRTY:
			name = "Dreckiges Wasser"
			_descr = "Nicht die Erstwahl, aber dennoch trinkbar."
			_comps.push_back(EMC_IC_Drink.new(1))
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(5))
			_comps.push_back(EMC_IC_Unpalatable.new(1))
		IDs.RAVIOLI_TIN:
			name = "Ravioli Konserve"
			_descr = "Kalt genießbar, aber ein Festmahl sieht anders aus.."
			_comps.push_back(EMC_IC_Food.new(1))
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(20))
		IDs.GAS_CARTRIDGE:
			name = "Gaskartusche"
			_descr = "Für den Gaskocher."
			_comps.push_back(EMC_IC_Cost.new(30))
		IDs.RAVIOLI_MEAL:
			name = "Ravioli Gericht"
			_descr = "Lecker schmecker!"
			_comps.push_back(EMC_IC_Food.new(2))
			_comps.push_back(EMC_IC_Cost.new(50))
		IDs.UNCOOKED_PASTA:
			name = "Ungekochte Nudeln"
			_descr = "Zu hart um sie roh zu essen, müssen erst gekocht werden."
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(20))
		IDs.COOKED_PASTA:
			name = "Nudeln"
			_descr = "Trockene, gekochte Nudeln. Die Definition von 'langweiligem Essen', aber machen satt."
			_comps.push_back(EMC_IC_Food.new(1))
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(20))
			_comps.push_back(EMC_IC_Shelflife.new(2))
		IDs.SAUCE_JAR:
			name = "Soße im Glas"
			_descr = "X"
			_comps.push_back(EMC_IC_Food.new(1))
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(20))
		IDs.PASTA_WITH_SAUCE:
			name = "Nudeln mit Soße"
			_descr = "X"
			_comps.push_back(EMC_IC_Food.new(2))
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(20))
			_comps.push_back(EMC_IC_Shelflife.new(2))
		IDs.BREAD:
			name = "Brot"
			_descr = "X"
			_comps.push_back(EMC_IC_Food.new(1))
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(20))
			_comps.push_back(EMC_IC_Shelflife.new(6))
		IDs.JAM:
			name = "Marmelade"
			_descr = "X"
			#_comps.push_back(EMC_IC_Ingredient.new())
			_comps.push_back(EMC_IC_Cost.new(20))
		IDs.BREAD_WITH_JAM:
			name = "Brot mit Marmelade"
			_descr = "X"
			_comps.push_back(EMC_IC_Food.new(1))
			_comps.push_back(EMC_IC_Shelflife.new(6))
		IDs.CHLOR_TABLETS:
			name = "Chlortablette"
			_descr = "Zum Wasser Filtern."
			_comps.push_back(EMC_IC_Cost.new(5))
			_comps.push_back(EMC_IC_Uses.new(3))
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


## Getter for concrete [EMC_ItemComponent]
## If no component of that type could be found, null is returned instead.
## Example of call:
##[codeblock]var item:= _backpack.get_item_of_slot(2)
##var ic_food: EMC_IC_Food = item.get_comp(EMC_IC_Food)
##if ic_food != null:
##	print(ic_food.get_formatted_values())[/codeblock]
func get_comp(p_classname: Variant) -> EMC_ItemComponent:
	for comp:EMC_ItemComponent in _comps:
		if is_instance_of(comp, p_classname):
			return comp
	return null


## Ability to add components
func add_comp(p_comp: EMC_ItemComponent) -> void:
	_comps.push_back(p_comp)


## Ability to remove components
func remove_comp(p_classname: Variant) -> void:
	var comp_to_be_removed := get_comp(p_classname)
	_comps.erase(comp_to_be_removed)


##@depracated
func copy_item() -> EMC_Item:
	var copied_item := _ITEM_SCN.instantiate()
	copied_item._ID = _ID
	copied_item._descr = _descr
	copied_item._comps = _comps
	return copied_item


########################################## PRIVATE METHODS #########################################
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = _ID


## TODO
func _on_gui_input(event: InputEvent) -> void:
	if ((event is InputEventMouseButton && event.pressed == true)):
	## Note: I removed the InputEventScreenTouch as it emited the clicked signal multiple times (Jakob)
	#or (event is InputEventScreenTouch)):
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
