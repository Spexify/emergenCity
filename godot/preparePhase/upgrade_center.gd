extends Control

@onready var _label_ecoins := $Background/VBoxContainer/MarginContainer/PanelContainer/HBoxContainer/RichTextLabel
@onready var _equipped_upgrades_display := [$Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Upgrade1,
											$Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Upgrade2,
											$Background/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Upgrade3]
@onready var _upgrade_list_display := $Background/VBoxContainer/PanelContainer2/VBoxContainer/ScrollContainer/GridContainer
@onready var _label_title := $Background/VBoxContainer/Description/MarginContainer/RichTextLabel
@onready var _label_descr := $Background/VBoxContainer/Description/RichTextLabel
const _upgrade_sprite_atlas := preload("res://preparePhase/upgrade.tscn")

var _equipped_upgrades : Array[EMC_Upgrade]
var _upgrade_list : Array[EMC_Upgrade]
var _balance : int = Global.get_e_coins()
var _last_clicked_upgrade : EMC_Upgrade


func _ready() -> void:
	_add_balance(0)
	
	_equipped_upgrades = Global.get_upgrades()
	
	for i in range(len(_equipped_upgrades_display)):
		_equipped_upgrades_display[i] = _upgrade_sprite_atlas.instantiate()
		
		if _equipped_upgrades[i] == null:
			_equipped_upgrades_display[i].get_sprite().set_frame(-1)
		else:
			_equipped_upgrades_display[i].get_sprite().set_frame_coords(_equipped_upgrades[i].get_tilemap_position())
	
	for id : EMC_Upgrade.IDs in EMC_Upgrade.IDs.values():
		_upgrade_list.append(EMC_Upgrade.new())
		_upgrade_list[-1].setup(id)
		_upgrade_list[-1].was_pressed.connect(_on_upgrade_pressed)
		
		var _upgrade_sprite : Control = _upgrade_sprite_atlas.instantiate()
		_upgrade_sprite.get_sprite().set_frame_coords(_upgrade_list[-1].get_tilemap_position())
		_upgrade_list_display.add_child(_upgrade_sprite)
	
	_upgrade_list_display.show()
		
func _add_balance(value : int) -> void:
	_balance += value
	_label_ecoins.clear()
	_label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")
	
func _on_upgrade_pressed(p_upgrade : EMC_Upgrade) -> void:
	_last_clicked_upgrade = p_upgrade
	
	_label_title.clear()
	_label_title.append_text("[color=black]" + p_upgrade.get_display_name() + "[/color]")
	_label_descr.clear()
	_label_descr.append_text("[color=black][i]" + p_upgrade.get_description() + "[/i][/color]")
	
func _add_upgrade(p_upgrade_id : EMC_Upgrade.IDs) -> bool:
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i] == null:
			_equipped_upgrades[i] = EMC_Upgrade.new()
			_equipped_upgrades[i].setup(p_upgrade_id)
			
			# adding the furniture-sprite to the GUI
			_equipped_upgrades_display[i].frame_coords = _equipped_upgrades[i].get_tilemap_position()
			
			return true
	return false
	
