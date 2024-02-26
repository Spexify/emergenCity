extends Control

@onready var _label_ecoins := $Background/VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/RichTextLabel
@onready var _equipped_upgrades := [$Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Upgrade1,
									$Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Upgrade2,
									$Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Upgrade3]
@onready var _upgrade_list := $Background/VBoxContainer/PanelContainer2/VBoxContainer/ScrollContainer/GridContainer
@onready var _label_title := $Background/VBoxContainer/Description/MarginContainer/RichTextLabel
@onready var _label_descr := $Background/VBoxContainer/Description/RichTextLabel
const _upgrade_scene := preload("res://preparePhase/upgrade.tscn")

var _balance : int = Global.get_e_coins()
var _last_clicked_upgrade : EMC_Upgrade


func _ready() -> void:
	_add_balance(0)
	
	_equipped_upgrades = Global.get_upgrades()
	
	for i in range(len(_equipped_upgrades)):
		_equipped_upgrades[i] = _upgrade_scene.instantiate()
		
		if _equipped_upgrades[i] != null:
			_equipped_upgrades[i].get_sprite().set_frame_coords(_equipped_upgrades[i].get_tilemap_position())
	
	for id : EMC_Upgrade.IDs in EMC_Upgrade.IDs.values():
		var _added_upgrade : EMC_Upgrade = _upgrade_scene.instantiate()
		_added_upgrade.setup(id)
		_added_upgrade.get_sprite().set_frame_coords(_added_upgrade.get_tilemap_position())
		
		_upgrade_list.add_child(_added_upgrade)
		
		
func _add_balance(value : int) -> void:
	_balance += value
	_label_ecoins.clear()
	_label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")
	
func _on_upgrade_pressed(p_upgrade : EMC_Upgrade) -> void:
	_last_clicked_upgrade = p_upgrade
	
	print("helldd")
	_label_title.clear()
	_label_title.append_text("[color=black]" + p_upgrade.get_display_name() + "[/color]")
	_label_descr.clear()
	_label_descr.append_text("[color=black][i]" + p_upgrade.get_description() + "[/i][/color]")
	
func _add_upgrade(p_upgrade_id : EMC_Upgrade.IDs) -> bool:
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i] == null:
			_equipped_upgrades[i] = _upgrade_scene.instantiate()
			_equipped_upgrades[i].setup(p_upgrade_id)
			_equipped_upgrades[i].set_framecoords(_equipped_upgrades[i].get_tilemap_position())
			return true
	return false
	
