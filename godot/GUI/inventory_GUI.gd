extends EMC_GUI
##Die GUI für das Anzeigen eines [EMC_Inventory]s des Spielers.
##
##Ein Inventar hat immer mehrere Slots, welche jeweils von bis zu einem [EC_Item]s belegt sein
##können oder nicht.
##Über toggleVisibility, open() und close() kann die Sichtbarkeit eingestellt werden.
##
##@tutorial(Mehr Infos in der Doku): https://sharelatex.tu-darmstadt.de/project/655b70099f37cc035f7e5fa4
class_name EMC_InventoryGUI

@onready var _label := $Inventory/VBC/Label
@onready var _slot_grid := $Inventory/VBC/ScrollContainer/GridContainer
@onready var _label_name := $Inventory/VBC/MarginContainer/TextBoxBG/VBC/Name
@onready var _label_comps := $Inventory/VBC/MarginContainer/TextBoxBG/VBC/Components
@onready var _label_descr := $Inventory/VBC/MarginContainer/TextBoxBG/VBC/Description
@onready var _consume_btn : Button = $Inventory/VBC/MG/HSC/CC/Consume
@onready var _discard_btn : Button = $Inventory/VBC/MG/HSC/HBC/Discard
@onready var _continue_btn : TextureButton = $Inventory/VBC/MG/HSC/HBC/Continue
@onready var _back_btn : TextureButton = $Inventory/VBC/MG/HSC/HBC/Back

const _SLOT_SCN: PackedScene = preload("res://GUI/inventory_slot.tscn")

var _inventory: EMC_Inventory
var _clicked_item : EMC_Item
var _avatar : EMC_Avatar
var _is_continue : bool #Distinguish between the modes of the normal inventory and the SEOD-version
var _gui_mngr : EMC_GUIMngr

########################################## PUBLIC METHODS ##########################################
## Konstruktror des Inventars
## Es können die Anzahl der Slots ([param p_slot_cnt]) sowie der initiale Titel
## ([param p_title]) gesetzt werden

func setup(p_inventory: EMC_Inventory, _p_avatar : EMC_Avatar, p_gui_mngr : EMC_GUIMngr, p_title: String = "Inventar") -> void:
	_inventory = p_inventory
	_avatar = _p_avatar
	_gui_mngr = p_gui_mngr
	set_title(p_title)
	
	for slot_idx in _inventory.get_slot_cnt():
		#Setup slot grid
		var new_slot := _SLOT_SCN.instantiate()
		#Add items that already are in the inventory
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null and item.get_ID() != JsonMngr.item_name_to_id("DUMMY"):
			item.clicked.connect(_on_item_clicked)
			new_slot.set_item(item)
		_slot_grid.add_child(new_slot)

## Set the title of inventory GUI
func set_title(p_new_text: String) -> void:
	_label.text = "[center]" + p_new_text + "[/center]"

func set_grid_height(height : int = 400) -> void:
	$Inventory/VBC/ScrollContainer.custom_minimum_size.y = height

func clear_items() -> void:
	for slot in $Inventory/VBC/ScrollContainer/GridContainer.get_children():
		slot.remove_item()

## Open the GUI
func open(p_is_continue : bool = false) -> void:
	_clear_gui()
	
	_is_continue = p_is_continue
	if _is_continue:
		_back_btn.hide()
		_continue_btn.show()
	else:
		_back_btn.show()
		_continue_btn.hide()
	
	_clicked_item = null
	show()
	opened.emit()
	_reload_items()

## Close the GUI
func close() -> void:
	hide()
	closed.emit(self)
	if _is_continue:
		_avatar.get_home()

########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$SpoiledVFX_Template.emitting = false

func _clear_gui() -> void:
	_consume_btn.hide()
	_discard_btn.hide()
	
	_label_name.clear()
	_label_comps.clear()
	_label_descr.clear()

## Display information of clicked [EMC_Item]
## Call with [param sender] == null to clear to default state.
func _on_item_clicked(p_clicked_item: EMC_Item) -> void:
	_clear_gui()
	
	_clicked_item = p_clicked_item
	_clicked_item.clicked_sound()
	#Name of the item
	_label_name.append_text("[color=black]" + _clicked_item.get_name() + "[/color]")
	
	#Components of item
	var comp_string: String = ""
	
	var comps := _clicked_item.get_comps()
	for comp in comps:
		var comp_text := comp.get_colored_name_with_vals()
		if comp_text != "":
			comp_string += comp_text + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	_label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	_label_descr.append_text("[color=black][i]" + _clicked_item.get_descr() + "[/i][/color]")
	
	#The activate the ones we need in the appropriate situation
	if not _is_continue:
		_discard_btn.show()
	if _item_consumable(_clicked_item) or _clicked_item.get_ID() == JsonMngr.item_name_to_id("CHLOR_TABLETS"):
		_consume_btn.show()
	
	#And set the custom text
	_consume_btn.text = _determine_consume_btn_text(_clicked_item)


func _item_consumable(item : EMC_Item) -> bool:
	#Commented as it shouldn't be usable in SEOD:
	#if item.get_ID() == JsonMngr.item_name_to_id("CHLOR_TABLETS"): 
		#return true
	#else:
	return item.get_comp(EMC_IC_Drink) != null or item.get_comp(EMC_IC_Food) != null


func _reload_items() -> void:
	_inventory.sort_custom(EMC_Inventory.sort_helper)
	
	for child in _slot_grid.get_children():
		child.remove_item()
		#_slot_grid.remove_child(child)
		
	for slot_idx in _inventory.get_slot_cnt():
		#Setup slot grid
		var new_slot := _slot_grid.get_children()[slot_idx]
		#Add items that already are in the inventory
		var item := _inventory.get_item_of_slot(slot_idx)
		if item != null and item.get_ID() != JsonMngr.item_name_to_id("DUMMY"):
			item.reset_modulate()
			##Code for Issue #25 Doesn't work, because if you click one item, it updates all the
			##other ones and removes the modulation... To cumbersome to fix rn
			#if !_only_inventory: 
				##Mark all items pitch-black, if they can't be consumed (eaten/drunk)
				#var IC_food := item.get_comp(EMC_IC_Food)
				#var IC_drink := item.get_comp(EMC_IC_Drink)
				#if IC_food == null && IC_drink == null:
					#item.modulate = Color(0, 0, 0)
			
			item.clicked.connect(_on_item_clicked)
			new_slot.set_item(item)
		
		_slot_grid.add_child(new_slot)
	
	call_deferred("_add_VFXs") #see. github.com/godotengine/godot/issues/30113


## CAUTION: Don't rename without changing the deffered call in _reload_items()
## If this is not called deferred, the positions of the slots are not correct (godot bug #30113)!
func _add_VFXs() -> void:
	#Reset VFX
	for child in $VFX_Instances.get_children():
		$VFX_Instances.remove_child(child)
	
	#Has to be done in extra loop, as only now the positions of the items are known
	for slot in _slot_grid.get_children():
		var item: EMC_Item = slot.get_item()
		if item != null:
			var IC_unpalatable := item.get_comp(EMC_IC_Unpalatable)
			if IC_unpalatable != null:
				#Spoiled VFX
				var new_spoiled_VFX := $SpoiledVFX_Template.duplicate()
				new_spoiled_VFX.emitting = true
				 #Magic number, dirty fix, no idea why the offset is needed:
				const WEIRD_OFFSET := Vector2(180, 270)
				new_spoiled_VFX.global_position = slot.position - WEIRD_OFFSET
				$VFX_Instances.add_child(new_spoiled_VFX)


func _on_consume_pressed() -> void:
	if _clicked_item == null:
		return
	if _clicked_item.get_ID() == JsonMngr.item_name_to_id("CHLOR_TABLETS"): 
		#$Inventory/VBoxContainer/HBoxContainer/Consume.text = "Filtern"
		if !_inventory.has_item(JsonMngr.item_name_to_id("WATER_DIRTY")):
			self.set_modulate(Color(0.4, 0.4, 0.4))
			await _gui_mngr.request_gui("TooltipGUI", ["Dreckiges Wasser zum Filtern ist nicht verfügbar."])
			self.set_modulate(Color(1.0, 1.0, 1.0))
		else:
			##Improvement idea: use new _inventory.use_item() method
			var comp_uses : EMC_IC_Uses = _clicked_item.get_comp(EMC_IC_Uses)
			comp_uses.use_item(1)
			_clicked_item.consumed_sound()
			# Work around to stop gray modulate
			_clicked_item.reset_modulate()
			
			if comp_uses.no_uses_left():
				_inventory.remove_specific_item(_clicked_item)
			
			_inventory.remove_item(JsonMngr.item_name_to_id("WATER_DIRTY"))
			_inventory.add_new_item(JsonMngr.item_name_to_id("WATER"))
	else:
		var drink_comp : EMC_IC_Drink = _clicked_item.get_comp(EMC_IC_Drink)
		var food_comp : EMC_IC_Food = _clicked_item.get_comp(EMC_IC_Food)
		_clicked_item.consumed_sound()
		if  drink_comp != null:
			_avatar.add_hydration(drink_comp.get_hydration())
		if food_comp != null:
			_avatar.add_nutrition(food_comp.get_nutritionness())
		var unpalatable_comp : EMC_IC_Unpalatable = _clicked_item.get_comp(EMC_IC_Unpalatable)
		if unpalatable_comp != null:
			_avatar.sub_health(unpalatable_comp.get_health_reduction())
		
		var pleasurable_comp : EMC_IC_Pleasurable = _clicked_item.get_comp(EMC_IC_Pleasurable)
		if pleasurable_comp != null:
			if pleasurable_comp.get_happiness_change() < 0:
				_avatar.sub_happiness(pleasurable_comp.get_happiness_change())
			elif pleasurable_comp.get_happiness_change() >= 0 :
				_avatar.add_happiness(pleasurable_comp.get_happiness_change())
				
		var healthy_comp : EMC_IC_Healthy = _clicked_item.get_comp(EMC_IC_Healthy)
		if healthy_comp != null:
			if healthy_comp.get_health_change() < 0:
				_avatar.sub_health(healthy_comp.get_health_change())
			elif healthy_comp.get_health_change() >= 0 :
				_avatar.add_health(healthy_comp.get_health_change())
				
		var hydrating_comp : EMC_IC_Hydrating = _clicked_item.get_comp(EMC_IC_Hydrating)
		if hydrating_comp != null:
			if hydrating_comp.get_hydration_change() < 0:
				_avatar.sub_hydration(hydrating_comp.get_hydration_change())
			elif hydrating_comp.get_hydration_change() >= 0 :
				_avatar.add_hydration(hydrating_comp.get_hydration_change())

		# Work around to stop gray modulate
		_clicked_item._on_clicked(EMC_Item.new())
		_inventory.remove_specific_item(_clicked_item)
		
	_reload_items()
	_clear_gui()

func _on_discard_pressed() -> void:
	_inventory.remove_specific_item(_clicked_item)
	SoundMngr.play_sound("TrashBin")
	_reload_items()
	_clear_gui()

func _determine_consume_btn_text(p_item: EMC_Item) -> String:
	if p_item.get_ID() == JsonMngr.item_name_to_id("CHLOR_TABLETS"):
		return tr("Filtern")
	
	var food_comp := p_item.get_comp(EMC_IC_Food)
	if food_comp != null:
		return tr("BP_EAT")
	
	var food_drink := p_item.get_comp(EMC_IC_Drink)
	if food_drink != null:
		return tr("Trinken")
	
	return tr("Konsumieren")
