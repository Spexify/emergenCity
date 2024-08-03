class_name EMC_Item_List
extends Control

const LIST_ITEM_SCN := preload("res://GUI/handy/list_item.tscn")

@onready var list :VBoxContainer = $List

func add_item(text : String, icon : Image, icon_region : Rect2) -> void:
	var list_item : Button = LIST_ITEM_SCN.instantiate()
	var _icon : Texture2D = ImageTexture.create_from_image(icon.get_region(icon_region))
	list_item.set_button_icon(_icon)
	list_item.set_text(text)
	list.add_child(list_item)
	
func clear() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.call_deferred("queue_free")
