extends EMC_ActionGUI

const ITEM_SCN : PackedScene = preload("res://items/item.tscn")
const RECIPE_SCN: PackedScene = preload("res://GUI/actionGUI/recipe.tscn")
var _inventory: EMC_Inventory
var _last_clicked_recipe: EMC_Recipe
var _confirmation_GUI: EMC_ConfirmationGUI
var _tooltipGUI: EMC_TooltipGUI
@onready var _recipe_list := $PanelContainer/MarginContainer/VBC/RecipeBox/ScrollContainer/RecipeList
@onready var _needs_water_icon : TextureRect = $PanelContainer/MarginContainer/VBC/PanelContainer/HBC/RestrictionList/NeedsWater
@onready var _needs_heat_icon : TextureRect = $PanelContainer/MarginContainer/VBC/PanelContainer/HBC/RestrictionList/NeedsHeat


########################################## PUBLIC METHODS ##########################################
func setup(p_inventory: EMC_Inventory, p_confirmationGUI: EMC_ConfirmationGUI, p_tooltipGUI: EMC_TooltipGUI) -> void:
	_inventory = p_inventory
	_confirmation_GUI = p_confirmationGUI
	_tooltipGUI = p_tooltipGUI
	
	for recipe : EMC_Recipe in JsonMngr.load_recipes():
		_recipe_list.add_child(recipe)
		recipe.was_pressed.connect(_on_recipe_pressed)

func open(p_action : EMC_Action) -> void:
	_action = p_action
	for recipe : EMC_Recipe in _recipe_list.get_children():
		recipe.disabled = !_recipe_cookable(recipe)
	_needs_water_icon.hide()
	_needs_heat_icon.hide()
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit()

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	hide()


func _on_cook_pressed() -> void:
	if _recipe_cookable(_last_clicked_recipe):
		if _last_clicked_recipe.needs_heat() && \
		OverworldStatesMngr.get_electricity_state() != OverworldStatesMngr.ElectricityState.UNLIMITED:
			_try_cooking_with_heat_source()
		else:
			_cook_recipe()


func _on_cancel_pressed() -> void:
	_last_clicked_recipe = null
	close()


func _on_recipe_pressed(p_recipe: EMC_Recipe) -> void:
	_last_clicked_recipe = p_recipe
	var input_items_list := $PanelContainer/MarginContainer/VBC/PanelContainer/HBC/ScrollContainer/InputItemList
	for unwanted_child : EMC_Item in input_items_list.get_children():
		input_items_list.remove_child(unwanted_child)
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		var item : EMC_Item = ITEM_SCN.instantiate()
		item.setup(input_item_ID)
		input_items_list.add_child(item)
		
	_needs_water_icon.visible = p_recipe.needs_water()
	_needs_heat_icon.visible = p_recipe.needs_heat()
	if p_recipe.needs_water() && \
	OverworldStatesMngr.get_water_state() != OverworldStatesMngr.WaterState.CLEAN:
		var water : EMC_Item = ITEM_SCN.instantiate()
		water.setup(EMC_Item.IDs.WATER)
		input_items_list.add_child(water)


func _recipe_cookable(p_recipe: EMC_Recipe) -> bool:
	if p_recipe == null:
		return false
	var counting_dict: Dictionary = {}
	for input_item_ID: EMC_Item.IDs in p_recipe.get_input_item_IDs():
		if counting_dict.has(input_item_ID):
			counting_dict[input_item_ID] += 1 
		else:
			counting_dict[input_item_ID] = 1 
	for counted_item_ID: EMC_Item.IDs in counting_dict.keys():
		if _inventory.get_item_count_of_ID(counted_item_ID, true) < counting_dict[counted_item_ID]:
			return false
	return true


func _cook_recipe() -> void:
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		_inventory.remove_item(input_item_ID)
	_inventory.add_new_item(_last_clicked_recipe.get_output_item_ID())
	
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = _action.play_sound()
	##Don't wait, because player has to wait too long otherwhise and there will be an 
	##animation playing simultatenously (Made SoundMngr process always)
	#if wait != null:
		#await wait.finished
	
	await $CookingAnimation.play(_last_clicked_recipe)
	#wait.stop() #Bug on mobile: Doesn't work, and waits endlessly!
	
	_action.executed.emit(_action)
	close()


func _try_cooking_with_heat_source() -> void:
	if Global.has_upgrade(EMC_Upgrade.IDs.GAS_COOKER):
		if _inventory.has_item(EMC_Item.IDs.GAS_CARTRIDGE):
			if await _confirmation_GUI.confirm("Willst eine Gaskartusche zum Kochen verwenden?"):
				_inventory.use_item(EMC_Item.IDs.GAS_CARTRIDGE)
				_cook_recipe()
		else:
			_tooltipGUI.open("Du hast zwar einen Gaskocher, aber keine Gaskartusche um ihn zu betreiben!")
	else:
		_tooltipGUI.open("Du hast weder Strom, noch einen Gaskocher zum Kochen!")

