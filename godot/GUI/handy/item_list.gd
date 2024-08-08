class_name EMC_Item_List
extends Control

const LIST_ITEM_SCN := preload("res://GUI/handy/list_item.tscn")

signal item_clicked(id : String)

@onready var list : VBoxContainer = $List

func add_item(text : String, icon : Texture2D, id : String = "") -> void:
	var list_item : Button = LIST_ITEM_SCN.instantiate()
	list_item.set_button_icon(icon)
	list_item.set_text(text)
	var callback : Callable = Callable(self, "_on_item_clicked").bind(id)
	list_item.pressed.connect(callback)
	list.add_child(list_item)
	
func clear() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.call_deferred("queue_free")

func _on_item_clicked(id : String) -> void :
	item_clicked.emit(id)
