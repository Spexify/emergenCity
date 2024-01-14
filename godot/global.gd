extends Node

var current_scene : Node = null

@onready var root := get_tree().root

var _e_coins : int = 100;
var _inventory : EMC_Inventory = null

var _start_scene : String = "res://preparePhase/main_menu.tscn"

const MAX_ECOINS = 99999
const SAVE_FILE = "user://savegame.save"


func _ready() -> void:
	var root := get_tree().root #MRM, editor-Warning: root is shadowed, variable should be renamed
	current_scene = root.get_child(root.get_child_count() - 1)
	_inventory = EMC_Inventory.new() #MRM: Sonst gibt es einen Null error wenn man die CRISIS PHASE..
									#.. ohne den Shop einmal geöffnet zu haben
	#Starterkit (for testing)
	_inventory.add_new_item(EMC_Item.IDs.UNCOOKED_PASTA)
	_inventory.add_new_item(EMC_Item.IDs.UNCOOKED_PASTA)
	_inventory.add_new_item(EMC_Item.IDs.SAUCE_JAR)
	_inventory.add_new_item(EMC_Item.IDs.COOKED_PASTA)
	_inventory.add_new_item(EMC_Item.IDs.BREAD)
	_inventory.add_new_item(EMC_Item.IDs.JAM)
	_inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)

func goto_scene(path: String) -> void:
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path: String) -> void:
	current_scene.free()

	var s := ResourceLoader.load(path) #MRM: One letter variables are a bad habit :( "scn" would be better
	current_scene = s.instantiate()
	root.add_child(current_scene)

func load_scene_name() -> String:
	return _start_scene

func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit() 
	
func reset_save() -> void:
	var save_game : FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	save_game.store_string("")
	
	load_game()
	
func save_game() -> void:
	var save_game : FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	
	var data : Dictionary = {
		"e_coins": _e_coins,
		"start_scene": "res://preparePhase/main_menu.tscn",
		"inventory_data": _inventory.get_all_items_as_ID().filter(func(item_id : EMC_Item.IDs) -> bool: return item_id != EMC_Item.IDs.DUMMY),
	}
	# JSON provides a static method to serialized JSON string.
	var json_string : String = JSON.stringify(data)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)
	
func load_game() -> void:
	return #MRM: Zum testen, sorry
	
	if not FileAccess.file_exists(SAVE_FILE):
		return # Error! We don't have a save to load.

	var save_game : FileAccess = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string : String = save_game.get_line()
	var json : JSON = JSON.new()

	var data : Dictionary

	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		data = {}
	else:
		data = json.get_data()
	
	_e_coins = data.get("e_coins", 100)
	_start_scene = data.get("start_scene", "res://preparePhase/main_menu.tscn")
	
	if data.get("inventory_data") == null:
		_inventory = EMC_Inventory.new()
		_inventory.add_new_item(EMC_Item.IDs.WATER)
		_inventory.add_new_item(EMC_Item.IDs.WATER)
		_inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
		_inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
		_inventory.add_new_item(EMC_Item.IDs.GAS_CARTRIDGE)
		_inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
		_inventory.sort_custom(EMC_Inventory.sort_helper)
	else:
		_inventory = EMC_Inventory.new()
		for item_id : int in data["inventory_data"]:
			_inventory.add_new_item(item_id)
			print(str(item_id))
			
		_inventory.sort_custom(EMC_Inventory.sort_helper)

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
