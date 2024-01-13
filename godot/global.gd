extends Node

var current_scene : Node = null

@onready var root := get_tree().root

var _e_coins : int = 100;
var _inventory : EMC_Inventory = null

const MAX_ECOINS = 99999

func _ready() -> void:
	var root := get_tree().root #MRM, editor-Warning: root is shadowed, variable should be renamed
	current_scene = root.get_child(root.get_child_count() - 1)
	
	_inventory = EMC_Inventory.new()
	_inventory.add_new_item(EMC_Item.IDs.WATER);
	_inventory.add_new_item(EMC_Item.IDs.WATER);
	_inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN);
	_inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN);
	_inventory.add_new_item(EMC_Item.IDs.GAS_CARTRIDGE);
	_inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY);
	_inventory.sort_custom(EMC_Inventory.sort_helper)

func goto_scene(path: String) -> void:
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String) -> void:
	current_scene.free()

	var s := ResourceLoader.load(path) #MRM: One letter variables are a bad habit :( "scn" would be better
	current_scene = s.instantiate()
	root.add_child(current_scene)

func load_scene_name() -> String:
	return "res://preparePhase/main_menu.tscn"
	
func load_save_file() -> void:
	pass
	
func save() -> void:
	pass

func get_e_coins() -> int:
	return _e_coins
	
func set_e_coins(e_coins : int) -> bool:
	if e_coins < 0 or e_coins > MAX_ECOINS:
		return false
	_e_coins = e_coins
	return true

func add_e_coins(e_coins : int) -> void:
	if _e_coins + e_coins > MAX_ECOINS:
		_e_coins = MAX_ECOINS
	else:
		_e_coins += e_coins
	
func sub_e_coins(e_coins : int) -> bool:
	if _e_coins - e_coins < 0 or e_coins < 0:
		return false
	else:
		_e_coins -= e_coins
		return true
		
func get_inventory() -> EMC_Inventory:
	return _inventory
	
func set_inventory(inventory : EMC_Inventory) -> void:
	_inventory = inventory
