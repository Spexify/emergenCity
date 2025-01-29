@tool
extends Control
class_name EMC_Item_Slot

const HIGHLIGHTED_COLOR := Color(0.4, 0.4, 0.4)
const DEFAULT_COLOR := Color(1, 1, 1)

@export var item: EMC_Item

@onready var item_button : TextureButton = $Slot_BG/ItemButton

var disabled: bool = false
var modulate_color: Color =  DEFAULT_COLOR

signal item_clicked(item : EMC_Item)
	
func _init() -> void:
	if Engine.is_editor_hint():
		item = EMC_Item.new()
	
func _ready() -> void:
	load_texture()
	item_button.set_disabled(disabled)
	self.set_modulate(modulate_color)

func load_texture() -> void:
	if item != null:
		item_button.set_texture_normal(item.get_texture())

func get_item() -> EMC_Item:
	return item

func set_item(p_item : EMC_Item) -> void:
	item = p_item
	if is_node_ready():
		load_texture()

func has_item() -> bool:
	return item.get_id() != EMC_Item.IDs.DUMMY
	
func remove_item() -> void:
	item = null
	if Engine.is_editor_hint():
		item = EMC_Item.new()
		
func free_item() -> void:
	item.free()
	if Engine.is_editor_hint():
		item = EMC_Item.new()

func disable() -> void:
	disabled = true
	if is_node_ready():
		item_button.set_disabled(disabled)

func block() -> void:
	disabled = true
	modulate_color = HIGHLIGHTED_COLOR
	if is_node_ready():
		item_button.set_disabled(disabled)
		self.set_modulate(modulate_color)

func unblock() -> void:
	disabled = false
	modulate_color = DEFAULT_COLOR
	if is_node_ready():
		item_button.set_disabled(disabled)
		self.set_modulate(modulate_color)
	
func is_blocked() -> bool:
	return disabled

func _on_item_button_pressed() -> void:
	item.clicked_sound()
	item_clicked.emit(item)

func _on_item_button_focus_entered() -> void:
	item_button.set_modulate(HIGHLIGHTED_COLOR)

func _on_item_button_focus_exited() -> void:
	item_button.set_modulate(DEFAULT_COLOR)
