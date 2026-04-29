@tool
extends FoldableContainer
class_name EMC_Foldable_Recipe

const ITEM_SLOT = preload("uid://cfk7h3ji5pkne")
const RECIPE_BUTTON = preload("uid://j5nyqj2o5l6f")

#@export var item: EMC_Item
#@export var text: String = "Brot"
@export var recipes: Array[EMC_Recipe]

@onready var recipe: EMC_Recipe_Button = $Margin/VBC/Panel/Margin/Recipe
@onready var vbc: VBoxContainer = $Margin/VBC

func _ready() -> void:
	
	recipe.recipe = recipes[0]
	var item := EMC_Item.new().setup(recipes[0].get_output_item_ID())
	var text := item.get_item_name()
	
	for rec: EMC_Recipe in recipes.slice(1):
		var recipe_button: EMC_Recipe_Button = RECIPE_BUTTON.instantiate()
		recipe_button.recipe = rec
		vbc.add_child(recipe_button)
	
	var hbox := HBoxContainer.new()
	var pic: EMC_Item_Slot = ITEM_SLOT.instantiate()
	pic.set_item(item)
	pic.set_size(Vector2(32, 32))
	#var pic := TextureRect.new()
	#pic.set_texture(icon)
	#pic.set_expand_mode(TextureRect.ExpandMode.EXPAND_FIT_WIDTH_PROPORTIONAL)
	#pic.set_size(Vector2(32, 32))
	hbox.add_child(pic)
	var button := Label.new()
	button.set_text(text)
	button.add_theme_font_size_override("font_size", 27)
	button.add_theme_color_override("font_color", Color())
	hbox.add_child(button)
	hbox.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	hbox.add_theme_constant_override("separation", 8)
	add_title_bar_control(hbox)
