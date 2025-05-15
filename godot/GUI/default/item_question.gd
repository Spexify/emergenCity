extends EMC_GUI
class_name EMC_ItemQuestion

@onready var confirm_btn : Button = $VBoxContainer/HBoxContainer/ConfirmBtn
@onready var back_btn : Button = $VBoxContainer/HBoxContainer/BackBtn
@onready var question : RichTextLabel = $VBoxContainer/PanelContainer/RichTextLabel
@onready var slot : EMC_Item_Slot = $VBoxContainer/CC/Slot

var _inventory : EMC_Inventory
var _item : EMC_Item
var _avatar : EMC_Avatar

func setup(p_inventory : EMC_Inventory, p_avatar : EMC_Avatar) -> void:
	_inventory = p_inventory
	_avatar = p_avatar

func open(p_item : EMC_Item, text : Dictionary = {}) -> void: 
	
	var question_text : String = text.get("question", "Möchstest du %s jetzt essen oder für später aufheben?")
	var answere_text : String = text.get("answere", "Essen")
	var decline_text : String = text.get("decline", "Aufheben")
	
	self.show()
	opened.emit()
	
	_item = p_item
	
	question.set_text(question_text % _item.name)
	if not answere_text.is_empty():
		confirm_btn.set_text(answere_text)
		confirm_btn.show()
	else:
		confirm_btn.hide()
	
	slot.set_item(_item)
	
func close() -> void:
	self.hide()
	closed.emit(self)

func _on_confirm_btn_pressed() -> void:
	slot.remove_item()
	_avatar.consume_item(_item)
	_inventory.remove_item(_item)
	close()

func _on_back_btn_pressed() -> void:
	slot.remove_item()
	close()
