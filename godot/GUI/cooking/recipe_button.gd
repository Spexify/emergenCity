
extends Button
class_name EMC_Recipe_Button

const ITEM_SLOT = preload("uid://cfk7h3ji5pkne")

@export var recipe: EMC_Recipe
@export var _gui_mngr: EMC_GUIMngr

@onready var ingredients: HBoxContainer = $Margin/HBC/Ingredients
@onready var output: EMC_Item_Slot = $Margin/HBC/Output
@onready var title: Label = $Margin/HBC/title
@onready var title_2: Label = $Margin/HBC/title2


func _ready() -> void:
	for item_id: int in recipe.get_input_item_IDs():
		var item_slot: EMC_Item_Slot = ITEM_SLOT.instantiate()
		ingredients.add_child(item_slot)
		item_slot.set_item(EMC_Item.new().setup(item_id))
		item_slot.item_long_pressed.connect(_on_item_long_pressed)
		
	var item: EMC_Item = EMC_Item.new().setup(recipe.get_output_item_ID())
	output.set_item(item)
	title.set_text(item.get_item_name())
	title_2.set_text(item.get_item_name())
	

func _on_item_long_pressed(item: EMC_Item, blocked: bool) -> void:
	_gui_mngr.request_gui("ItemInfoGui", [item])
