extends Control
class_name EMC_Item

static var ITEMS_TEXTURE : Texture2D = preload("res://res/sprites/items.png")

signal clicked(sender: EMC_Item)

##Better use: JsonMngr.item_name_to_id(<string from item_ids.json>)
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
 	FLOUR = 14,
	SALT = 15,
	SUGAR = 16, 
	RICE = 17,
	PULSES = 18,
	FISH = 19,
	POTATOES = 20,
	VEGETABLES = 21,
	FRUITS = 22,
	CHOCOLATE = 23,
	MEAT = 24,
	TOFU = 25,
	NUTS = 26,
	CHEESE = 27,
	MILK = 28,
	BOLOGNESE = 29,
	JUICE = 30,
	SALTED_FISH = 31,
	PICKLED_VEGETABLES = 32,
	RICE_WITH_VEGETABLES = 33,
	CURRY_WITH_RICE = 34,
	HUMMUS_WITH_BREAD = 35,
	CHEESE_SANDWICH = 36,
	HOT_CHOCOLATE = 37,
	GOULASH = 38,
	MILK_RICE = 39,
	SOUP = 40,
	BATTERIES = 41,
	SOAP = 42,
}

const HIGHLIGHTED_COLOR := Color(0.4, 0.4, 0.4)
const DEFAULT_COLOR := Color(1, 1, 1)

#FYI: Inherits "name" property from Node
var _ID: IDs
var _descr: String = "<No Descr>"
var _comps: Array[EMC_ItemComponent]
var _sound_effect : Dictionary = { 
	"clicked" : "BasicItem",
	"consumed" : "",
	}

static var _ITEM_SCN : PackedScene = preload("res://items/item.tscn")

########################################## PUBLIC METHODS ##########################################
##Initialize properties
func setup(p_ID: int = IDs.DUMMY) -> void:
	#await ready
	_ID = p_ID
	
	var data : Dictionary = JsonMngr.get_item_vars_from_id(_ID)
	
	name = data.get("name", "Dummy")
	_descr = data.get("descr", "Error: Someone tempered with the JsonMngr.")
	_sound_effect = data.get("sound", _sound_effect)
	var tmp_comps : Array = data.get("comps", [])
	_comps.assign(tmp_comps.map(func (data : Dictionary) -> EMC_ItemComponent : return  EMC_ItemComponent.from_dict(data)))


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
	for comp : EMC_ItemComponent in _comps:
		if is_instance_of(comp, p_classname):
			return comp
	return null

func get_all_comps_of(p_classname: Variant) -> Array[EMC_ItemComponent]:
	var result : Array[EMC_ItemComponent]
	for comp : EMC_ItemComponent in _comps:
		if is_instance_of(comp, p_classname):
			result.append(comp)
	return result

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


## This Method returns all infomation the Item in form of a Dictionary
func to_dict() -> Dictionary:
	var dict_comps := []
	
	for comp in _comps:
		dict_comps.append(comp.to_dict())
	
	var data : Dictionary = {
		"ID": _ID,
		"name" : name,
		"descr" : _descr,
		"sound": _sound_effect,
		"comps": dict_comps,
	}
	
	return data


## This Method returns relevant infomation of the Item in form of a Dictionary.
## Relevant information includes:
## - ID
## - comps
func to_save() -> Dictionary:
	var dict_comps := []
	
	for comp in _comps:
		dict_comps.append(comp.to_dict())
	
	var data : Dictionary = {
		"ID": _ID,
		"comps": dict_comps,
	}
	
	return data


## Returns a new Item constructed out of a Dictionary containing all information of the Item
static func from_dict(data : Dictionary) -> EMC_Item:
	var item : EMC_Item = _ITEM_SCN.instantiate()
	item._ID = data.get("ID", 0)
	item.name = data.get("name", "Dummy")
	item._descr = data.get("descr", "Error")
	item._sound_effect = data.get("sound", item._sound_effect)
	var tmp_comps : Array = data.get("comps", [])
	item._comps.assign(tmp_comps.map(func (data : Dictionary) -> EMC_ItemComponent : return  EMC_ItemComponent.from_dict(data)))
	
	return item


## Returns a new Item constructed out of a Dictionary containing relevant information of the Item.
## For this to work JsonMngr must already have loaded all Items.
## Relevant Infromation is:
## - ID
## - comps
static func from_save(data : Dictionary) -> EMC_Item:
	var item : EMC_Item = _ITEM_SCN.instantiate()
	
	item._ID = data.get("ID", 0)
	
	var default_info : Dictionary = JsonMngr.get_item_vars_from_id(item._ID)
	
	item.name = default_info.get("name", "Dummy")
	item._descr = default_info.get("descr", "Error: Someone tempered with the JsonMngr.")
	item._sound_effect = default_info.get("sound", item._sound_effect)
	var tmp_comps : Array = data.get("comps", [])
	item._comps.assign(tmp_comps.map(func (data : Dictionary) -> EMC_ItemComponent : return  EMC_ItemComponent.from_dict(data)))
	
	return item
	
static func make_from_id(item_id : int) -> EMC_Item:
	var item : EMC_Item = _ITEM_SCN.instantiate()
	item.setup(item_id)
	return item

func consumed_sound() -> void:
	SoundMngr.play_sound(_sound_effect["consumed"])


func clicked_sound(pitch : float = 1) -> void:
	SoundMngr.play_sound(_sound_effect["clicked"], 0, pitch)


########################################## PRIVATE METHODS #########################################
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Sprite2D.set_frame(_ID)
	const ITEM_ICON_WIDTH := 64
	const ITEM_PNG_COLS = 10
	var x_offset: int = (_ID % ITEM_PNG_COLS) * ITEM_ICON_WIDTH
	var y_offset: int = (floor(_ID / ITEM_PNG_COLS)) * ITEM_ICON_WIDTH
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(ITEMS_TEXTURE)
	atlas_texture.set_region(Rect2(x_offset, y_offset, ITEM_ICON_WIDTH, ITEM_ICON_WIDTH))
	$TextureButton.texture_normal = atlas_texture


## TODO
#func _on_gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton && event.pressed == true and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
	### Note: I removed the InputEventScreenTouch as it emited the clicked signal multiple times (Jakob)
	##or (event is InputEventScreenTouch)):
		#clicked.emit(self)
		##Calls _on_clicked(self) for all instances of signal group "items":
		#Global.get_tree().call_group("items", "_on_clicked", self) 


## TODO
func _on_clicked(sender: EMC_Item) -> void:
	if sender == null:
		printerr("Item._on_clicked(): Sender ist null!")
	elif sender == self:
		self.modulate = HIGHLIGHTED_COLOR
	else:
		self.modulate = DEFAULT_COLOR
		
func reset_modulate() -> void:
	self.modulate = DEFAULT_COLOR

func _on_texture_button_pressed() -> void:
	clicked.emit(self)
	#Calls _on_clicked(self) for all instances of signal group "items":
	Global.get_tree().call_group("items", "_on_clicked", self) 
