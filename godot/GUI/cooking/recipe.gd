extends TextureButton
class_name EMC_Recipe


###Tupe-Klasse (alles public und keine Methoden)
#
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

	var item : EMC_Item = EMC_Item.make_from_id(p_outputItemID)
	var sprite := TextureRect.new()
	sprite.set_texture(item.get_texture())
	$HBoxContainer.add_child(sprite)
	$HBoxContainer/RichTextLabel.text = item.get_name()

func get_input_item_IDs() -> Array[EMC_Item.IDs]:
	return _input_item_IDs

func get_output_item_ID() -> EMC_Item.IDs:
	return _output_item_ID

func needs_water() -> bool:
	return _needs_water

func needs_heat() -> bool:
	return _needs_heat
	
func _on_pressed() -> void:
	was_pressed.emit(self)
