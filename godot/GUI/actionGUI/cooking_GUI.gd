extends EMC_ActionGUI

const RECIPE_SCN: PackedScene = preload("res://GUI/actionGUI/recipe.tscn")
var _inventory: EMC_Inventory
var _last_clicked_recipe: EMC_Recipe

var _gui_mngr : EMC_GUIMngr
var _day_mngr : EMC_DayMngr

@onready var _recipe_list := $PanelContainer/MarginContainer/VBC/RecipeBox/ScrollContainer/RecipeList
@onready var _needs_water_icon : TextureRect = $PanelContainer/MarginContainer/VBC/PanelContainer/HBC/RestrictionList/NeedsWater
@onready var _needs_heat_icon : TextureRect = $PanelContainer/MarginContainer/VBC/PanelContainer/HBC/RestrictionList/NeedsHeat
@onready var _input_item_list : HBoxContainer = $PanelContainer/MarginContainer/VBC/PanelContainer/HBC/ScrollContainer/InputItemList


########################################## PUBLIC METHODS ##########################################
func setup(p_inventory: EMC_Inventory, p_gui_mngr : EMC_GUIMngr, p_day_mngr : EMC_DayMngr) -> void:
	_inventory = p_inventory
	_gui_mngr = p_gui_mngr
	_day_mngr = p_day_mngr
	
	var recipes_dict : Dictionary
	for recipe : EMC_Recipe in JsonMngr.load_recipes():
		#_recipe_list.add_child(recipe)
		recipe.was_pressed.connect(_on_recipe_pressed)
		if recipes_dict.has(recipe.get_output_item_ID()):
			recipes_dict[recipe.get_output_item_ID()].append(recipe)
		else:
			recipes_dict[recipe.get_output_item_ID()] = [recipe]
			
	for mother : int in recipes_dict:
		if recipes_dict.get(mother).size() == 1:
			_recipe_list.add_child(recipes_dict.get(mother)[0])
		else:
			var casted_array : Array[EMC_Recipe]
			casted_array.assign(recipes_dict.get(mother))
			var mother_scn : EMC_MotherRecipe = EMC_MotherRecipe.make(mother, casted_array)
			_recipe_list.add_child(mother_scn)
			closed.connect(mother_scn.hide_children)
	

func open() -> void:
	for recipe : Variant in _recipe_list.get_children():
		if recipe is EMC_MotherRecipe:
			
			var all_disabled : bool = true
			for child in (recipe as EMC_MotherRecipe).get_child_recipes():
				if not _recipe_cookable(child):
					recipe.move_child(child, -1)
					child.set_disabled(true) 
				all_disabled = all_disabled and child.is_disabled()
			if all_disabled:
				_recipe_list.move_child(recipe, -1)
				recipe.set_disabled(true)
		else:
			if not _recipe_cookable(recipe):
				_recipe_list.move_child(recipe, -1)
				recipe.set_disabled(true) 
	
	# DEBUG: check whether recipes are correctly sorted
	#print(_recipe_list.get_children().map(func(recipe:Variant) -> bool: return recipe.is_disabled()))
	
			
	_needs_water_icon.hide()
	_needs_heat_icon.hide()
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)
	

static func sort_recipe(a : Variant, b : Variant) -> bool:
	if a == null:
		return false
	if b == null:
		return true
	return (not a.is_disabled()) and b.is_disabled()

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
	for unwanted_child : TextureRect in _input_item_list.get_children():
		_input_item_list.remove_child(unwanted_child)
		unwanted_child.queue_free()
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		var item : EMC_Item = EMC_Item.make_from_id(input_item_ID)
		var sprite := TextureRect.new()
		sprite.set_texture(item.get_texture())
		_input_item_list.add_child(sprite)
		
	_needs_water_icon.visible = p_recipe.needs_water()
	_needs_heat_icon.visible = p_recipe.needs_heat()
	if (p_recipe.needs_water() and OverworldStatesMngr.get_water_state() != OverworldStatesMngr.WaterState.CLEAN):
		if Global.has_upgrade(EMC_Upgrade.IDs.WATER_RESERVOIR) and Global.get_upgrade_if_equipped(EMC_Upgrade.IDs.WATER_RESERVOIR).get_state() > 0:
			return
		var water : EMC_Item = EMC_Item.make_from_id(EMC_Item.IDs.WATER)
		var sprite := TextureRect.new()
		sprite.set_texture(water.get_texture())
		_input_item_list.add_child(sprite)


func _recipe_cookable(p_recipe: EMC_Recipe) -> bool:
	if p_recipe == null:
		return false
	var counting_dict: Dictionary = {}
	for input_item_ID: EMC_Item.IDs in p_recipe.get_input_item_IDs():
		if counting_dict.has(input_item_ID):
			counting_dict[input_item_ID] += 1 
		else:
			counting_dict[input_item_ID] = 1 
	for id: EMC_Item.IDs in counting_dict.keys():
		var filter := EMC_Util.combine_filters(EMC_Inventory.filter_id(id), EMC_Inventory.filter_not_comp(EMC_IC_Unpalatable))
		if _inventory.get_items_filterd(filter).size() < counting_dict[id]:
			return false
	return true


func _cook_recipe() -> void:
	if (_last_clicked_recipe.needs_water() and OverworldStatesMngr.get_water_state() != OverworldStatesMngr.WaterState.CLEAN
		and Global.has_upgrade(EMC_Upgrade.IDs.WATER_RESERVOIR)):
			var  reservoir := Global.get_upgrade_if_equipped(EMC_Upgrade.IDs.WATER_RESERVOIR)
			if reservoir.get_state() > 0:
				reservoir.set_state(reservoir.get_state() - 25)
			
			
	for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		_inventory.remove_item_by_id(input_item_ID)
		
	var output_item : EMC_Item = EMC_Item.make_from_id(_last_clicked_recipe.get_output_item_ID())
	_inventory.add_item(output_item)
	
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = SoundMngr.play_sound("Cooking")
	##Don't wait, because player has to wait too long otherwhise and there will be an 
	##animation playing simultatenously (Made SoundMngr process always)
	#if wait != null:
		#await wait.finished
	
	_gui_mngr.queue_gui("CookingAnimation", [_last_clicked_recipe])
	#wait.stop() #Bug on mobile: Doesn't work, and waits endlessly!
	
	if not _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.EVENING:
		_gui_mngr.queue_gui("ItemQuestionGUI", [output_item])
	
	close()
	#_action.executed.emit(_action)
	_day_mngr._advance_day_period("Du hast %s gekocht" % output_item.name)

func _try_cooking_with_heat_source() -> void:
	if Global.has_upgrade(EMC_Upgrade.IDs.GAS_COOKER):
		if _inventory.has_item(EMC_Item.IDs.GAS_CARTRIDGE):
			if await _gui_mngr.request_gui("ConfirmationGUI", ["Willst eine Gaskartusche zum Kochen verwenden?"]):
				_inventory.use_item(EMC_Item.IDs.GAS_CARTRIDGE)
				_cook_recipe()
		else:
			_gui_mngr.request_gui("TooltipGUI", ["Du hast zwar einen Gaskocher, aber keine Gaskartusche um ihn zu betreiben!"])
	else:
		_gui_mngr.request_gui("TooltipGUI", ["Du hast weder Strom, noch einen Gaskocher zum Kochen!"])

