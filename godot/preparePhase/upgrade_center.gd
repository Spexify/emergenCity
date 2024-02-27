extends Control

@onready var _label_ecoins := $Background/VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/RichTextLabel
@onready var _equipped_upgrades_display := $Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer
@onready var _upgrade_list := $Background/VBoxContainer/PanelContainer2/VBoxContainer/ScrollContainer/GridContainer
@onready var _label_title := $Background/VBoxContainer/Description/MarginContainer/RichTextLabel
@onready var _label_descr := $Background/VBoxContainer/Description/RichTextLabel
const _upgrade_scene := preload("res://preparePhase/upgrade.tscn")
const _number_of_equipment_slots : int = 3 # the upgrade array in Global needs to be changed accordingly
var _balance : int = Global.get_e_coins()
var _last_clicked_upgrade : EMC_Upgrade
var _equipped_upgrades : Array[EMC_Upgrade]


func _ready() -> void:
	_add_balance(0)
	
	_equipped_upgrades = Global.get_upgrades()
	
	for id : EMC_Upgrade.IDs in EMC_Upgrade.IDs.values():
		var _added_upgrade : EMC_Upgrade = null
		for i in range(len(_equipped_upgrades)):
			if _equipped_upgrades[i] != null && _equipped_upgrades[i].get_id() == id:
				_added_upgrade = _equipped_upgrades[i]
				_equipped_upgrades_display.add_child(_added_upgrade)
		
		
		# if there is no equipped upgrade with this id
		if _added_upgrade == null:
			_added_upgrade = _upgrade_scene.instantiate()
			_added_upgrade.setup(id)
			_added_upgrade.get_sprite().set_frame_coords(_added_upgrade.get_tilemap_position())
		
		if !(_added_upgrade.get_id() == EMC_Upgrade.IDs.EMPTY_SLOT):
			_added_upgrade.was_pressed.connect(_on_upgrade_pressed)
			_upgrade_list.add_child(_added_upgrade)
	
	# if there are free equipment-slots, fill them with EMPTY_SLOT
	if _equipped_upgrades_display.get_child_count() < _number_of_equipment_slots:
		for i in range(len(_equipped_upgrades)):
			if(_equipped_upgrades[i] == null):
				var empty_slot : EMC_Upgrade = _upgrade_scene.instantiate()
				empty_slot.setup(EMC_Upgrade.IDs.EMPTY_SLOT)
				_equipped_upgrades[i] = empty_slot
				_equipped_upgrades_display.add_child(empty_slot)


func _add_balance(value : int) -> void:
	_balance += value
	_label_ecoins.clear()
	_label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")
	
func _on_upgrade_pressed(p_upgrade : EMC_Upgrade) -> void:
	_last_clicked_upgrade = p_upgrade
	
	_label_title.clear()
	_label_title.append_text("[color=black]" + p_upgrade.get_display_name() + "[/color]")
	_label_title.append_text("   [color=Color.GOLDENROD][i]" + str(p_upgrade.get_price()) + "eCoins [/i][/color]")
	_label_descr.clear()
	_label_descr.append_text("[color=black][i]" + p_upgrade.get_description() + "[/i][/color]")
	
	# check if upgrade is already equipped
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i] != null && _equipped_upgrades[i].get_id() == _last_clicked_upgrade.get_id():
			$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/BuyBtn.hide()
			$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/EquipBtn.hide()
			return
	# check if upgrade is already unlocked
	var _upgrade_ids_unlocked : Array[EMC_Upgrade.IDs] = Global.get_upgrade_ids_unlocked()
	if _last_clicked_upgrade.get_id() in _upgrade_ids_unlocked:
		$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/BuyBtn.hide()
		$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/EquipBtn.show()
	else:
		$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/BuyBtn.show()
		$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/EquipBtn.hide()


func _on_buy_btn_pressed() -> void:
	if _balance >= _last_clicked_upgrade.get_price():
		_add_balance(-_last_clicked_upgrade.get_price())
		Global.unlock_upgrade_id(_last_clicked_upgrade.get_id())
		$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/BuyBtn.hide()
		$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/EquipBtn.show()


func _on_equip_btn_pressed() -> void:
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i].get_id() == EMC_Upgrade.IDs.EMPTY_SLOT:
			_equipped_upgrades_display.remove_child(_equipped_upgrades[i])
			_equipped_upgrades[i] = _last_clicked_upgrade
			_equipped_upgrades_display.add_child(_last_clicked_upgrade)
			$Background/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/EquipBtn.hide()
			return
