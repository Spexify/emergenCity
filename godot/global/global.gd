extends Node

@onready var root := get_tree().root

const MAX_ECOINS = 99999
const INITIAL_E_COINS = 500

const SAVE_GAME_FILE = "user://savegame.save"
const SAVE_STATE_FILE = "user://savestate.save"
const PREPARE_PHASE_SCENE = "res://preparePhase/main_menu.tscn"
const CONTINUE_SCENE = "res://preparePhase/continue.tscn"
const CRISIS_PHASE_SCENE = "res://crisisPhase/crisis_phase.tscn"

const SAVEFILE_AVATAR_SKIN := "avatar_skin"

var _e_coins : int = 500
var _inventory : EMC_Inventory = null

var current_scene : Node = null
var _start_scene : String
var _was_crisis : bool
var _in_crisis_phase: bool
var _crisis_length : int = 3
var _number_crisis_overlap : int = 3


func _ready() -> void:
	var root := get_tree().root #MRM, editor-Warning: root is shadowed, variable should be renamed
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(path: String) -> void:
	match path:
		PREPARE_PHASE_SCENE: _in_crisis_phase = false
		CONTINUE_SCENE: _in_crisis_phase = false #MRM: Eig. uneindeutig, vllt ein enum statt bool draus machen?
		CRISIS_PHASE_SCENE: _in_crisis_phase = true
		_: _in_crisis_phase = false
	
	call_deferred("_deferred_goto_scene", path)


func is_in_crisis_phase() -> bool:
	return _in_crisis_phase


func _deferred_goto_scene(path: String) -> void:
	#current_scene.free() # Wenn die current scene gefreed würde, wird das inventar gelöscht
	get_tree().root.remove_child(current_scene) 

	var s := ResourceLoader.load(path) #MRM: One letter variables are a bad habit :( "scn" would be better
	current_scene = s.instantiate()
	root.add_child(current_scene)


func load_scene_name() -> String:
	return _start_scene


func was_crisis() -> bool:
	return _was_crisis


func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: 
		save_game(current_scene.name == "CrisisPhase")
		get_tree().quit() 


func reset_save() -> void:
	var save_game : FileAccess = FileAccess.open(SAVE_GAME_FILE, FileAccess.WRITE)
	
	var data : Dictionary = {
		"was_crisis": _was_crisis,
		"master_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))),
		"sfx_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))),
		"musik_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musik"))),
		SAVEFILE_AVATAR_SKIN: EMC_AvatarSelectionGUI.SPRITE_NB03
	}
	# JSON provides a static method to serialized JSON string.
	var json_string : String = JSON.stringify(data)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)
	save_game.flush()
		
	load_game()


func reset_state() -> void:
	var save_game : FileAccess = FileAccess.open(SAVE_STATE_FILE, FileAccess.WRITE)
	save_game.store_string("")


func save_game(was_crisis : bool) -> void:
	
	if _inventory == null:
		#MRM: I want to test partial Scenes with F6 but it still tries to save
		return
	###################SAVE GAME######################
	
	var save_game : FileAccess = FileAccess.open(SAVE_GAME_FILE, FileAccess.WRITE)
	
	var data : Dictionary = {
		"e_coins": _e_coins,
		"was_crisis": was_crisis,
		"inventory_data": _inventory.get_all_items_as_ID().filter(func(item_id : EMC_Item.IDs) -> bool: return item_id != EMC_Item.IDs.DUMMY),
		"master_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))),
		"sfx_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))),
		"musik_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musik"))),
		SAVEFILE_AVATAR_SKIN: SettingsGUI.get_avatar_sprite_suffix(),
	}
	# JSON provides a static method to serialized JSON string.
	var json_string : String = JSON.stringify(data)

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(json_string)
	
	##################SAVE STATE#####################
	
	var save_state : FileAccess = FileAccess.open(SAVE_STATE_FILE, FileAccess.WRITE)
	var save_nodes : Array[Node] = get_tree().get_nodes_in_group("Save")
	for node in save_nodes:
		# Check the node has a save function.
		if !node.has_method("save"):
			print("Save node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data : Dictionary = node.call("save")

		# JSON provides a static method to serialized JSON string.
		json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_state.store_line(json_string)


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_GAME_FILE):
		FileAccess.open(SAVE_GAME_FILE, FileAccess.WRITE).store_string("")

	var save_game : FileAccess = FileAccess.open(SAVE_GAME_FILE, FileAccess.READ)
	var json_string : String = save_game.get_line()
	var json : JSON = JSON.new()

	var data : Dictionary

	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		data = {}
	else:
		data = json.get_data()
	
	_e_coins = data.get("e_coins", INITIAL_E_COINS)
	
	_was_crisis = data.get("was_crisis", false)
	if not _was_crisis:
		_start_scene = PREPARE_PHASE_SCENE
	else:
		_start_scene = CONTINUE_SCENE
	
	if data.get("inventory_data") == null:
		_inventory = create_inventory_with_starting_items()
	else:
		_inventory = EMC_Inventory.new()
		for item_id : int in data["inventory_data"]:
			_inventory.add_new_item(item_id)
			
		_inventory.sort_custom(EMC_Inventory.sort_helper)
		
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(data.get("master_volume", 1)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(data.get("sfx_volume", 1)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(data.get("musik_volume", 1)))
	$SFX/Musik.set_autoplay(true)
	$SFX/Musik.set_volume_db(linear_to_db(data.get("musik_volume", 1)))
	$SFX/Musik.play() 
	
	var avatar_skin: Variant = data.get(SAVEFILE_AVATAR_SKIN)
	if avatar_skin != null:
		SettingsGUI.set_avatar_sprite_suffix(avatar_skin)


## A default inventory when the game save state is reset/a crisis ended
func create_inventory_with_starting_items() -> EMC_Inventory:
	var inventory := EMC_Inventory.new()
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
	inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
	#inventory.add_new_item(EMC_Item.IDs.GAS_CARTRIDGE)
	inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
	inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
	inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
	inventory.add_new_item(EMC_Item.IDs.UNCOOKED_PASTA)
	inventory.add_new_item(EMC_Item.IDs.UNCOOKED_PASTA)
	inventory.add_new_item(EMC_Item.IDs.SAUCE_JAR)
	inventory.add_new_item(EMC_Item.IDs.BREAD)
	inventory.add_new_item(EMC_Item.IDs.JAM)
	inventory.add_new_item(EMC_Item.IDs.CHLOR_TABLETS)
	inventory.sort_custom(EMC_Inventory.sort_helper)
	return inventory


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_STATE_FILE):
		return

	var save_game : FileAccess = FileAccess.open(SAVE_STATE_FILE, FileAccess.READ)
	var json : JSON = JSON.new()

	var data : Dictionary
	
	while save_game.get_position() < save_game.get_length():
		var json_string : String = save_game.get_line()
		
		var parse_result : Error = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data : Dictionary = json.get_data()

		var new_object : NodePath = node_data["node_path"]
		get_node(new_object).load_state(node_data)

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

func set_crisis_difficulty(_p_crisis_length : int = 3, 
							_p_number_crisis_overlap : int = 2) -> void:
	_crisis_length = _p_crisis_length
	_number_crisis_overlap = _p_number_crisis_overlap

func get_number_crisis_overlap() -> int:
	return _number_crisis_overlap

func get_crisis_length() -> int:
	return _crisis_length
