extends Control

@onready var _label_ecoins := $Background/VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/RichTextLabel

# This display only holds copies of the equipped upgrades, which are visually the same but not connected to _on_upgrade_pressed
@onready var _equipped_upgrades_display := $Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer

@onready var _upgrade_list := $Background/VBoxContainer/PanelContainer2/VBoxContainer/ScrollContainer/GridContainer
@onready var _label_title := $Background/VBoxContainer/WhitePanel/VBoxContainer/MarginContainer/UpgradeName
@onready var _label_price := $Background/VBoxContainer/WhitePanel/VBoxContainer/Price
@onready var _label_descr := $Background/VBoxContainer/WhitePanel/VBoxContainer/Description
@onready var _buy_btn := $Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/BuyBtn
@onready var _equip_btn := $Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/EquipBtn
@onready var _star_explosion_VFX := $StarExplosionVFX

const _upgrade_scene := preload("res://preparePhase/upgrade.tscn")
const _number_of_equipment_slots : int = 3 # the upgrade array in Global needs to be changed accordingly
var _balance : int = Global.get_e_coins()
var _last_clicked_upgrade : EMC_Upgrade
var _equipped_upgrades : Array[EMC_Upgrade]


func _ready() -> void:
	_add_balance(0)
	
	_equipped_upgrades = Global.get_upgrades()
	print(_equipped_upgrades)
	
	for id : EMC_Upgrade.IDs in EMC_Upgrade.IDs.values():
		var _added_upgrade : EMC_Upgrade = null
		# already equipped upgrades are instantiated and setup in Global
		for i in range(len(_equipped_upgrades)):
			if _equipped_upgrades[i] != null && _equipped_upgrades[i].get_id() == id:
				_added_upgrade = _equipped_upgrades[i]
				
				_equipped_upgrades_display.add_child(_added_upgrade)
		
		
		# if there is no equipped upgrade with this id
		if _added_upgrade == null:
			_added_upgrade = _upgrade_scene.instantiate()
			_added_upgrade.setup(id)
		
		if !(_added_upgrade.get_id() == EMC_Upgrade.IDs.EMPTY_SLOT):
			_added_upgrade.was_pressed.connect(_on_upgrade_pressed)
			
			#if locked, visually mark it 100% black
			var locked: bool = true
			var _upgrade_ids_unlocked: Array[EMC_Upgrade.IDs] = Global.get_upgrade_ids_unlocked()
			for _upgrade_id_unlocked in _upgrade_ids_unlocked:
				if _added_upgrade.get_id() == _upgrade_id_unlocked:
					locked = false
			if locked:
				_added_upgrade.set_modulation(Color(0.0, 0.0, 0.0))
			
			_upgrade_list.add_child(_added_upgrade)
	
	# if there are free equipment-slots, fill them with EMPTY_SLOT
	if _equipped_upgrades_display.get_child_count() < _number_of_equipment_slots:
		for i in range(len(_equipped_upgrades)):
			if(_equipped_upgrades[i] == null):
				var empty_slot : EMC_Upgrade = _upgrade_scene.instantiate()
				empty_slot.setup(EMC_Upgrade.IDs.EMPTY_SLOT)
				_overwrite_upgrade_at_idx(i, empty_slot)


func _add_balance(value : int) -> void:
	_balance += value
	_label_ecoins.clear()
	_label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")


func _on_upgrade_pressed(p_upgrade : EMC_Upgrade) -> void:
	_last_clicked_upgrade = p_upgrade
	
	_label_title.clear()
	_label_title.append_text("[color=black]" + p_upgrade.get_display_name() + "[/color]")
	
	const price_color = Color.GOLDENROD
	_label_price.clear()
	_label_price.append_text("[color=" + price_color.to_html(false) + "]" + str(p_upgrade.get_price()) + "eC[/color]")
	
	_label_descr.clear()
	_label_descr.append_text("[color=black][i]" + p_upgrade.get_description() + "[/i][/color]")
	
	# check if upgrade is already equipped
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i].get_id() == _last_clicked_upgrade.get_id():
			_buy_btn.hide()
			_equip_btn.hide()
			return
	# check if upgrade is already unlocked
	var _upgrade_ids_unlocked : Array[EMC_Upgrade.IDs] = Global.get_upgrade_ids_unlocked()
	if _last_clicked_upgrade.get_id() in _upgrade_ids_unlocked:
		_buy_btn.hide()
		_equip_btn.show()
	else:
		_buy_btn.show()
		_equip_btn.hide()


func _on_buy_btn_pressed() -> void:
	if _balance >= _last_clicked_upgrade.get_price():
		_add_balance(-_last_clicked_upgrade.get_price())
		Global.unlock_upgrade_id(_last_clicked_upgrade.get_id())
		Global.set_e_coins(_balance)
		_buy_btn.hide()
		_equip_btn.show()
		
		_last_clicked_upgrade.set_modulation(Color(1.0, 1.0, 1.0))
		#Play VFX at position of unlocked upgrade
		_star_explosion_VFX.position = _last_clicked_upgrade.global_position + _last_clicked_upgrade.size/2
		_star_explosion_VFX.emitting = true


func _on_equip_btn_pressed() -> void:
	# see if there is a mutually exclusive upgrade already equipped and remove it
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i].get_spawn_pos() == _last_clicked_upgrade.get_spawn_pos():
			# the corresponding display_slot should be at the same index:
			if _equipped_upgrades_display.get_child(i).get_id() != _equipped_upgrades[i].get_id():
				push_error("Unerwarteter Fehler: Upgrades equipped and their display are out of sync")
				
			var empty_slot : EMC_Upgrade = _upgrade_scene.instantiate()
			empty_slot.setup(EMC_Upgrade.IDs.EMPTY_SLOT)
			_overwrite_upgrade_at_idx(i, empty_slot)
	
	# look for an empty slot
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i].get_id() == EMC_Upgrade.IDs.EMPTY_SLOT:
			# the corresponding display_slot should be at the same index:
			if _equipped_upgrades_display.get_child(i).get_id() != EMC_Upgrade.IDs.EMPTY_SLOT:
				push_error("Unerwarteter Fehler: Upgrades equipped and their display are out of sync")
			
			_overwrite_upgrade_at_idx(i, _last_clicked_upgrade)
			
			_equip_btn.hide()
			return

func _overwrite_upgrade_at_idx(idx: int, new_upgrade : EMC_Upgrade) -> void:
	
	_equipped_upgrades[idx] = new_upgrade
	_equipped_upgrades_display.remove_child(_equipped_upgrades_display.get_child(idx))
	
	var display_copy : EMC_Upgrade = _upgrade_scene.instantiate()
	display_copy.setup(new_upgrade.get_id())
	_equipped_upgrades_display.add_child(display_copy)
	_equipped_upgrades_display.move_child(display_copy, idx)


func _on_main_menu_btn_pressed() -> void:
	var tmp : Array[EMC_Upgrade] 
	for i in range(len(_equipped_upgrades)):
		var up := _upgrade_scene.instantiate()
		up.setup(_equipped_upgrades[i].get_id())
		tmp.append(up)
	
	print(tmp)
	Global.set_upgrades(tmp)
	Global.goto_scene(Global.MAIN_MENU_SCENE)
