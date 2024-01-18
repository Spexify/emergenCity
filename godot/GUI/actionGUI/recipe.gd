extends TextureButton
class_name EMC_Recipe
#


###Tupe-Klasse (alles public und keine Methoden)
#
const ITEM_SCN : PackedScene = preload("res://items/item.tscn")
signal was_pressed(p_recipe : EMC_Recipe)

var _input_item_IDs: Array[EMC_Item.IDs]
var _output_item_ID: EMC_Item.IDs

var _needs_water : bool
var _needs_heat : bool

func setup(p_inputItemIDs : Array[EMC_Item.IDs], p_outputItemID: EMC_Item.IDs, p_needs_water : bool, \
p_needs_heat : bool) -> void:
	_input_item_IDs = p_inputItemIDs
	_output_item_ID = p_outputItemID
	_needs_water = p_needs_water
	_needs_heat = p_needs_heat
	#await ready
	#var item : EMC_Item = ITEM_SCN.instantiate()
	#item.setup(p_outputItemID)
	#$HBoxContainer/item.replace_by(item)
	var item := $HBoxContainer/item
	item.setup(p_outputItemID)
	$HBoxContainer/RichTextLabel.text = item.get_name()
	#item.set_frame()


func get_input_item_IDs() -> Array[EMC_Item.IDs]:
	return _input_item_IDs

func get_output_item_ID() -> EMC_Item.IDs:
	return _output_item_ID

###Konstruktor
##func init():
	##pass


func _on_pressed() -> void:
	was_pressed.emit(self)
