extends Control

@onready var _label_ecoins := $Background/MarginContainer/VBoxContainer/PanelContainer3/HBoxContainer/RichTextLabel

@onready var upgrades_display : GridContainer = $Background/MarginContainer/VBoxContainer/UpgradePanel/VBC/ScrollContainer/GridContainer

@onready var _label_title := $Background/MarginContainer/VBoxContainer/WhitePanel/VBoxContainer/MarginContainer/UpgradeName
@onready var _label_price := $Background/MarginContainer/VBoxContainer/WhitePanel/VBoxContainer/Price
@onready var _label_descr := $Background/MarginContainer/VBoxContainer/WhitePanel/VBoxContainer/Description
@onready var _buy_btn := $Background/MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/BuyBtn
@onready var _equip_btn := $Background/MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/EquipBtn
@onready var _un_equip_btn := $Background/MarginContainer/VBoxContainer/MarginContainer3/HBoxContainer/VBoxContainer/UnEquipBtn
@onready var _star_explosion_VFX := $StarExplosionVFX

const _upgrade_scene := preload("res://preparePhase/upgrade.tscn")
const _number_of_equipment_slots : int = 3 # the upgrade array in Global needs to be changed accordingly
var _balance : int = Global.get_e_coins()
var _last_clicked_upgrade : EMC_Upgrade
var _equipped_upgrades : Array[EMC_Upgrade]


func _ready() -> void:
	_add_balance(0)
	
	for id : int in EMC_Upgrade.IDs.values():
		if id == EMC_Upgrade.IDs.EMPTY_SLOT:
			continue
		
		var upgrade := _upgrade_scene.instantiate()
		upgrade.setup(id)
		upgrade.was_pressed.connect(_on_upgrade_pressed)
		
		if id not in Global.get_upgrade_ids_unlocked():
			upgrade.set_modulation(Color(0.0, 0.0, 0.0))
			
		if Global.has_upgrade(id):
			upgrade.self_modulate = Color(0.302, 0.698, 0.392)
			_equipped_upgrades.append(upgrade)
		
		upgrades_display.add_child(upgrade)

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
			_un_equip_btn.show()
			return
	# check if upgrade is already unlocked
	var _upgrade_ids_unlocked : Array[EMC_Upgrade.IDs] = Global.get_upgrade_ids_unlocked()
	if _last_clicked_upgrade.get_id() in _upgrade_ids_unlocked:
		_buy_btn.hide()
		_equip_btn.show()
		_un_equip_btn.hide()
	else:
		_buy_btn.show()
		_equip_btn.hide()
		_un_equip_btn.hide()


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
		
		_on_equip_btn_pressed()
	else:
		SoundMngr.play_sound("BasicItem", 0, 0.4)


func _on_equip_btn_pressed() -> void:
	# see if there is a mutually exclusive upgrade already equipped and remove it
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i].get_spawn_pos() == _last_clicked_upgrade.get_spawn_pos():
			_equipped_upgrades[i].self_modulate = Color(1.0, 1.0, 1.0)
			_equipped_upgrades.remove_at(i)
			_equipped_upgrades.append(_last_clicked_upgrade)
			_last_clicked_upgrade.self_modulate = Color(0.302, 0.698, 0.392)
			_equip_btn.hide()
			return
			
	if _equipped_upgrades.size() < 3:
		_equipped_upgrades.append(_last_clicked_upgrade)
		_last_clicked_upgrade.self_modulate = Color(0.302, 0.698, 0.392)
		_equip_btn.hide()
	else:
		SoundMngr.play_sound("clicked", 1, 0.4)

func _on_un_equip_btn_pressed() -> void:
	_last_clicked_upgrade.self_modulate = Color(1.0, 1.0, 1.0)
	_equipped_upgrades.erase(_last_clicked_upgrade)
	
	_un_equip_btn.hide()

func _on_main_menu_btn_pressed() -> void:
	var tmp : Array[EMC_Upgrade] 
	for i in range(len(_equipped_upgrades)):
		var up := _upgrade_scene.instantiate()
		up.setup(_equipped_upgrades[i].get_id())
		tmp.append(up)
	
	Global.set_upgrades(tmp)
	Global.goto_scene(Global.MAIN_MENU_SCENE)
