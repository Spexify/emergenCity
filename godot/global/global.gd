extends Node

const MAX_ECOINS = 99999
const INITIAL_E_COINS = 300

const SAVE_GAME_FILE = "user://savegame.save"
const SAVE_STATE_FILE = "user://savestate.save"
const MAIN_MENU_SCENE = "res://preparePhase/main_menu.tscn"
const CONTINUE_SCENE = "res://preparePhase/continue.tscn"
const CRISIS_PHASE_SCENE = "res://crisisPhase/crisis_phase.tscn"
const FIRST_GAME_SCENE = "res://global/first_game.tscn"
const INFORMATION_SCENE = "res://preparePhase/information.tscn"
const CREDIT_SCENE = "res://preparePhase/credit_information.tscn"
const CRISIS_START_SCENE = "res://preparePhase/crisis_start.tscn"
const SHOP_SCENE = "res://preparePhase/shop.tscn"
const UPGRADE_CENTER_SCENE = "res://preparePhase/upgrade_center.tscn"

const UPGRADE_SCENE_PRELOAD = preload("res://preparePhase/upgrade.tscn")

const SAVEFILE_AVATAR_SKIN := "avatar_skin"

signal game_loaded
signal scene_changed

@onready var _root := get_tree().root
var _tutorial_done : bool = false
var _e_coins : int = 500
var _inventory : EMC_Inventory = null
var _upgrades_equipped : Array[EMC_Upgrade] = [null, null, null]
var _upgrade_ids_unlocked : Array[EMC_Upgrade.IDs] = []
var _current_scene : Node = null
var _start_scene : String
var _was_crisis : bool
var _in_crisis_phase: bool
var _started_from_entry_scene: bool = false
var _vibration : bool = false
var _apps_installed : Array[String] = []


## This function and variable are there, so you can later distinguish if the project
## was started normally (F5) or only for a certain scene (F6)
func set_started_from_entry_scene(p_value: bool = true) -> void:
	_started_from_entry_scene = p_value

func _ready() -> void:
	var root := get_tree().root 
	_current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String) -> void:
	match path:
		MAIN_MENU_SCENE: _in_crisis_phase = false
		CONTINUE_SCENE: _in_crisis_phase = false
		CRISIS_PHASE_SCENE: _in_crisis_phase = true
		_: _in_crisis_phase = false
	
	call_deferred("_deferred_goto_scene", path)


func is_in_crisis_phase() -> bool:
	return _in_crisis_phase


func _deferred_goto_scene(path: String) -> void:
	get_tree().root.remove_child(_current_scene)
	_current_scene.queue_free()
	
	var scn : PackedScene = ResourceLoader.load(path)
	_current_scene = scn.instantiate()
	_root.add_child(_current_scene)
	scene_changed.emit()


func load_scene_name() -> String:
	return _start_scene


func was_crisis() -> bool:
	return _was_crisis


## MRM: For what is this?? Sometimes I randomly get a crash in save_game
func _notification(what : int) -> void:
	#should prevent saving problems when starting a stand-along scene (F6):
	if !_started_from_entry_scene: return 
	
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game(_current_scene.name == "CrisisPhase")
		##This leads to the game crashing if you open the mobile-task manager and try to continue
		##the game:
		#get_tree().quit() 


func reset_save() -> void:
	var save_game_file : FileAccess = FileAccess.open(SAVE_GAME_FILE, FileAccess.WRITE)
	
	reset_inventory()
	reset_upgrades_equipped()
	
	var data : Dictionary = {
		"was_crisis": _was_crisis,
		"master_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))),
		"sfx_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))),
		"musik_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musik"))),
		SAVEFILE_AVATAR_SKIN: EMC_AvatarSelectionGUI.SPRITE_NB03,
		"inventory_data": _inventory.get_all_items().map(func (item : EMC_Item) -> Dictionary: return item.to_save()),
		#"upgrade_ids_unlocked": _upgrade_ids_unlocked, # Should upgrades be persisitent over resets?
		"tutorial_done" : false,
		"vibration" : false,
		"apps_installed": [],
	}
	# JSON provides a static method to serialized JSON string.
	var json_string : String = JSON.stringify(data)

	# Store the save dictionary as a new line in the save file.
	save_game_file.store_line(json_string)
	save_game_file.flush()
		
	load_game()


func reset_state() -> void:
	var save_game_file : FileAccess = FileAccess.open(SAVE_STATE_FILE, FileAccess.WRITE)
	
	var data : Dictionary = {}
	
	var json_string : String = JSON.stringify(data)
	
	save_game_file.store_string(json_string)
	save_game_file.flush()


func reset_inventory() -> void:
	_inventory = create_inventory_with_starting_items()


func reset_upgrades_equipped() -> void:
	_upgrades_equipped = [null, null, null]


func save_game(p_was_crisis : bool) -> void:
	var save_game_file : FileAccess = FileAccess.open(SAVE_GAME_FILE, FileAccess.WRITE)
	
	var data : Dictionary = {
		"e_coins": _e_coins,
		"was_crisis": p_was_crisis,
		"inventory_data": _inventory.get_items().map(func (item : EMC_Item) -> Dictionary: return item.to_save()),
		"upgrade_ids_unlocked": _upgrade_ids_unlocked,
		"upgrades_equipped" : _upgrades_equipped.map(func (_upgrade : EMC_Upgrade) -> int : return _upgrade.get_id() if _upgrade != null else EMC_Upgrade.IDs.EMPTY_SLOT),
		"master_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))),
		"sfx_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))),
		"musik_volume": db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musik"))),
		SAVEFILE_AVATAR_SKIN: SettingsGUI.get_avatar_sprite_suffix(),
		"tutorial_done" : _tutorial_done,
		"vibration" : _vibration,
		"apps_installed" : _apps_installed,
	}
	# JSON provides a static method to serialized JSON string.
	var json_string : String = JSON.stringify(data)
	
	# Store the save dictionary as a new line in the save file.
	save_game_file.store_line(json_string)
	
	##################SAVE STATE#####################
	if p_was_crisis:
		var save_state : FileAccess = FileAccess.open(SAVE_STATE_FILE, FileAccess.WRITE)
		var save_nodes : Array[Node] = get_tree().get_nodes_in_group("Save")
		for node in save_nodes:
			# Check the node has a save function.
			if !node.has_method("save"):
				printerr("Save node '%s' is missing a save() function, skipped" % node.name)
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

	var save_game_file : FileAccess = FileAccess.open(SAVE_GAME_FILE, FileAccess.READ)
	var json_string : String = save_game_file.get_line()
	var json : JSON = JSON.new()

	var data : Dictionary

	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		data = {}
	else:
		data = json.get_data()
	
	_e_coins = data.get("e_coins", INITIAL_E_COINS)
	
	_was_crisis = data.get("was_crisis", false)
	if not _was_crisis:
		_start_scene = MAIN_MENU_SCENE
	else:
		_start_scene = CONTINUE_SCENE
	
	if data.get("inventory_data") == null:
		_inventory = create_inventory_with_starting_items()
	else:
		_inventory = EMC_Inventory.new()
		for item_dict : Dictionary in data["inventory_data"]:
			_inventory.add_item(EMC_Item.from_save(item_dict))
			
		_inventory.sort_custom(EMC_Inventory.sort_by_id)
		
	_upgrade_ids_unlocked.assign(data.get("upgrade_ids_unlocked", []))
	
	_upgrades_equipped.assign(data.get("upgrades_equipped", [0, 0, 0]).map(func (id : int) -> EMC_Upgrade: var res := UPGRADE_SCENE_PRELOAD.instantiate(); res.setup(id); return res))
	
	_vibration = data.get("vibration", false)
		
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(data.get("master_volume", 1)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(data.get("sfx_volume", 1)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(data.get("musik_volume", 1)))
	if not SoundMngr.is_musik_playing():
		SoundMngr.play_musik() 
	
	_tutorial_done = data.get("tutorial_done", false)
	
	var avatar_skin: String = data.get(SAVEFILE_AVATAR_SKIN, "ERROR")
	if avatar_skin != "ERROR" && Global._tutorial_done:
		SettingsGUI.set_avatar_sprite_suffix(avatar_skin)
		
	_apps_installed.assign(data.get("apps_installed", []))
		
	game_loaded.emit()


## A default inventory when the game save state is reset/a crisis ended
func create_inventory_with_starting_items() -> EMC_Inventory:
	var inventory := EMC_Inventory.new()
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
	inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
	inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
	inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
	inventory.add_new_item(EMC_Item.IDs.UNCOOKED_PASTA)
	inventory.add_new_item(EMC_Item.IDs.SAUCE_JAR)
	inventory.add_new_item(EMC_Item.IDs.BREAD)
	inventory.add_new_item(EMC_Item.IDs.JAM)
	
	inventory.sort_custom(EMC_Inventory.sort_by_id)
	return inventory


func load_state() -> void:
	if not FileAccess.file_exists(SAVE_STATE_FILE):
		return

	var save_game_file : FileAccess = FileAccess.open(SAVE_STATE_FILE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	while save_game_file.get_position() < save_game_file.get_length():
		var json_string : String = save_game_file.get_line()
		
		var parse_result : Error = json.parse(json_string)
		if not parse_result == OK:
			printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var node_data : Dictionary = json.get_data()
		
		var new_object : Variant = node_data.get("node_path")
		if new_object:
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

func get_equipped_upgrades() -> Array[EMC_Upgrade]:
	return _upgrades_equipped.filter(func(upgrade : EMC_Upgrade) -> bool: return upgrade != null and upgrade.get_id() != EMC_Upgrade.IDs.EMPTY_SLOT)

func get_upgrade_if_equipped(p_ID: EMC_Upgrade.IDs) -> EMC_Upgrade:
	for upgrade in _upgrades_equipped:
		if upgrade.get_id() == p_ID:
			return upgrade
	return null

func get_upgrades() -> Array[EMC_Upgrade]:
	return _upgrades_equipped


func set_upgrades(upgrades : Array[EMC_Upgrade]) -> void:
	_upgrades_equipped = upgrades


func get_upgrade_ids_unlocked() -> Array[EMC_Upgrade.IDs]:
	return _upgrade_ids_unlocked


func unlock_upgrade_id(upgrade_id : EMC_Upgrade.IDs) -> void:
	_upgrade_ids_unlocked.append(upgrade_id)


func has_upgrade(upgrade_id : EMC_Upgrade.IDs) -> bool:
	for upgrade in _upgrades_equipped:
		if upgrade != null && upgrade.get_id() == upgrade_id:
			return true
	return false

func set_vibration_enabled(x : bool) -> void:
	_vibration = x

func is_vibration_enabled() -> bool:
	return _vibration

################################################UTIL################################################

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
## DEPRECATED
func pick_weighted_random(list : Array[Variant], weights : Array[float], count : int) -> Array[Variant]:
	var result : Array[Variant] = []
	assert(count <= list.size(), "Count cannot be greater than list size")
	assert(list.size() == weights.size(), "The size of list and weights must be equal")
	for i in range(count):
		var sum_of_weight : float = weights.reduce(func(a : float, b : float) -> float: return a + b)
		var random : float = _rng.randf_range(0.0, sum_of_weight)
		for index in range(list.size()):
			if random < weights[index]:
				result.append(list[index])
				list.remove_at(index)
				weights.remove_at(index)
				break
			random -= weights[index]
	return result
