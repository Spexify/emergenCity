extends Control
##Ein Inventar des Spielers.
##
##Ein Inventar hat immer mehrere Slots, welche jeweils von bis zu einem [EC_Item]s belegt sein
##können oder nicht.
##Über toggleVisibility, open() und close() kann die Sichtbarkeit eingestellt werden.  
##Die beinhalteten Items kann man über die jeweiligen Methoden verwalten.
##@tutorial(Mehr Infos in der Doku): https://sharelatex.tu-darmstadt.de/project/655b70099f37cc035f7e5fa4
class_name EC_Inventory

signal opened
signal closed

const MAX_SLOT_CNT: int = 50
var _slot_scn: PackedScene = preload("res://items/inventory_slot.tscn")
var _slot_cnt: int
var _item_scn: PackedScene = preload("res://items/item.tscn")


#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Die Sichtbarkeit umstellen.
func toggleVisibility() -> void:
	if visible == false:
		open()
	else:
		close()

## Das Inventar sichtbar machen.
func open():
	visible = true
	opened.emit()

## Das Inventar verstecken.
func close():
	visible = false
	closed.emit()


## Diesem Inventar ein neues [EC_Item] hinzufügen.
## Gibt True zurück, falls das Item hinzugefügt wurde, sonst false.
func add_new_item(ID: EC_Item.IDs) -> bool:
	var new_item = _item_scn.instantiate()
	new_item.setup(ID, self)
	return add_item(new_item)


## Diesem Inventar ein bestehendes [EC_Item] hinzufügen.
## Gibt True zurück, falls das Item hinzugefügt wurde, sonst false.
func add_item(item: EC_Item) -> bool:
	var gridcont : GridContainer = get_node("Background/VBoxContainer/GridContainer")
	
	for i in _slot_cnt:
		var slot = gridcont.get_child(i)
		if slot.is_free():
			slot.set_item(item)
			return true
	return false


##Item ID an Position ermitteln
func get_item_ID_of_slot(slot_cnt: int) -> EC_Item.IDs:
#	return $Background/VBoxContainer/GridContainer
#TODO
	return EC_Item.IDs.DUMMY


## Diesem Inventar ein Item [param cnt] Mal entfernen entfernen
## Gibt die Anzahl an erfolgreich entfernten Items zurück
func remove_item(ID: EC_Item.IDs, toBeRemovedCnt: int = 1) -> int:
	var removedCnt: int = 0
	for slotIdx in _slot_cnt:
		var slot = $Background/VBoxContainer/GridContainer.get_child(slotIdx)
		var item = slot.get_item()
		if item._ID == ID: #TODO: Lieber Getter statt direkter Zugriff auf private Attr.
			slot.remove_child(item)
			removedCnt += 1
	return removedCnt


## Das Inventar ist im Besitz von Item
func has_item(ID: EC_Item.IDs) -> bool:
	#TODO
	return false


## Das Inventar ist im Besitz von Item
func has_item_n_times(ID: EC_Item.IDs) -> int:
	#TODO
	return -1


## Informationen zu einem Item in der TextBox anzeigen
func display_info(item: EC_Item) -> void:
	#print("Info zu " + item._name)
	var label = $Background/VBoxContainer/MarginContainer/TextBoxBG/Label
	label.clear()
	label.append_text("[color=black]" + item._name + "[/color]
	")
	label.append_text("[i][color=black]" + item._descr + "[/color][/i]")
	pass


#----------------------------------------- PRIVATE METHODS -----------------------------------------
#MRM: Eig. in eigene init() Methode auszulagern, da man _init() nicht mit Parametern aufrufen kann:
func _init(p_slotCnt : int = 30): 
	_slot_cnt = p_slotCnt
	if (_slot_cnt > MAX_SLOT_CNT): _slot_cnt = MAX_SLOT_CNT


# Called when the node enters the scene tree for the first time.
func _ready():
	var gridcont : GridContainer = get_node("Background/VBoxContainer/GridContainer")
	
	for i in _slot_cnt:
		var new_slot = _slot_scn.instantiate()
		gridcont.add_child(new_slot)
	
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

#func _on_btn_backpack_released():
#	get_viewport().set_input_as_handled() #needed, otherwhise it directly closes the window again


func _on_btn_backpack_pressed():
	get_viewport().set_input_as_handled()
	open()
