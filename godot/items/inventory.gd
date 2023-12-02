extends Control
##Ein Inventar des Spielers.
##
##Ein Inventar hat immer mehrere Slots, welche jeweils von bis zu einem [EC_Item]s belegt sein
##können oder nicht.
##Über toggleVisibility, open() und close() kann die Sichtbarkeit eingestellt werden.  
##Die beinhalteten Items kann man über die jeweiligen Methoden verwalten.
##
##@tutorial(Mehr Infos in der Doku): https://sharelatex.tu-darmstadt.de/project/655b70099f37cc035f7e5fa4
class_name EMC_Inventory

signal opened
signal closed

const MAX_SLOT_CNT: int = 50
var _slot_scn: PackedScene = preload("res://items/inventory_slot.tscn")
var _slot_cnt: int = 30
var _item_scn: PackedScene = preload("res://items/item.tscn")


#------------------------------------------ PUBLIC METHODS -----------------------------------------
## Konstruktro des Inventars
## Es können die Anzahl der Slots ([param p_slot_cnt]) sowie der initiale Titel
## ([param p_title]) gesetzt werden
func setup(p_slot_cnt: int = 30, p_title: String = "Inventar"):
	_slot_cnt = p_slot_cnt
	if (_slot_cnt > MAX_SLOT_CNT): _slot_cnt = MAX_SLOT_CNT
	setTitle(p_title)


## Die Überschrift der Inventar-UI setzen
func setTitle(newText: String):
	$Background/Label.text = "[center]" + newText + "[/center]"


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


## Gibt zurück, ob noch Platz im Inventar vorhanden ist
func has_space() -> bool:
	return get_item_count() < _slot_cnt


## Diesem Inventar ein neues [EMC_Item] hinzufügen.
## Gibt True zurück, falls das Item hinzugefügt wurde, sonst false.
func add_new_item(ID: EMC_Item.IDs) -> bool:
	var new_item = _item_scn.instantiate() #EMC_Item.new(ID, self) 
	new_item.setup(ID, self)
	return add_item(new_item)


## Diesem Inventar ein bestehendes [EMC_Item] hinzufügen.
## Gibt True zurück, falls das Item hinzugefügt wurde, sonst false.
func add_item(item: EMC_Item) -> bool:
	var gridcont : GridContainer = get_node("Background/VBoxContainer/GridContainer")
	
	for i in _slot_cnt:
		var slot = gridcont.get_child(i)
		if slot.is_free():
			item.clicked.connect(_on_item_clicked)
			slot.set_item(item)
			return true
	return false


##Item ID an Position ermitteln
func get_item_ID_of_slot(slot_cnt: int) -> EMC_Item.IDs:
#	return $Background/VBoxContainer/GridContainer
	#TODO
	return EMC_Item.IDs.DUMMY


## Diesem Inventar ein [EMC_Item] [param cnt] Mal entfernen entfernen
## Gibt die Anzahl an erfolgreich entfernten Items zurück
func remove_item(ID: EMC_Item.IDs, toBeRemovedCnt: int = 1) -> int:
	var removedCnt: int = 0
	
	for slotIdx in _slot_cnt:
		var slot = $Background/VBoxContainer/GridContainer.get_child(slotIdx)
		var item = slot.get_item()
		if item != null && item.get_ID() == ID:
			slot.remove_child(item)
			removedCnt += 1
	return removedCnt


## Das Inventar ist im Besitz von mindestens einem [EMC_Item] mit dieser ID
func has_item(ID: EMC_Item.IDs) -> bool:
	for slotIdx in _slot_cnt:
		var slot = $Background/VBoxContainer/GridContainer.get_child(slotIdx)
		var item = slot.get_item()
		if item != null && item.get_ID() == ID:
			return true
	return false


## Gibt die Anzahl an [EMC_Item]s dieses Typ zurück
func get_item_count_of_ID(ID: EMC_Item.IDs) -> int:
	var cnt: int = 0
	
	for slotIdx in _slot_cnt:
		var slot = $Background/VBoxContainer/GridContainer.get_child(slotIdx)
		var item = slot.get_item()
		if item != null && item.get_ID() == ID:
			cnt += 1
	return cnt


## Gibt die Gesamtanzahl an [EMC_Item]s zurück
func get_item_count() -> int:
	var cnt: int = 0
	
	for slotIdx in _slot_cnt:
		var slot = $Background/VBoxContainer/GridContainer.get_child(slotIdx)
		var item = slot.get_item()
		if item != null:
			cnt += 1
	return cnt


## Alle Items des Inventars als Array an [EMC_Items] liefern
func get_all_items() -> Array[EMC_Item]:
	var items: Array[EMC_Item]
	
	for slotIdx in _slot_cnt:
		var slot = $Background/VBoxContainer/GridContainer.get_child(slotIdx)
		var item = slot.get_item()
		if item != null:
			items.push_back(item)
	return items


## Items nach ID sortieren (QoL feature in der Zukunft)
func sort() -> void: #Man könnte ein enum als Parameter ergänzen, nach was sortiert werden soll
	#TODO (keine Prio)
	pass


#----------------------------------------- PRIVATE METHODS -----------------------------------------
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
	

func _on_btn_backpack_pressed():
	get_viewport().set_input_as_handled()
	open()


## Informationen zu einem Item in der TextBox anzeigen
func _on_item_clicked(sender: EMC_Item) -> void:
	#Name des Items
	var label_name = $Background/VBoxContainer/MarginContainer/TextBoxBG/Name
	label_name.clear()
	label_name.append_text("[color=black]" + sender.get_name() + "[/color]")
	
	#Komponenten des Items
	var comps := sender.get_comps()
	var comp_string: String
	for comp in comps:
		comp_string += comp.get_colored_name_with_vals() + ", "
	##Überflüssiges Komma entfernen:
	comp_string = comp_string.left(comp_string.length() - 2)
	var label_comps = $Background/VBoxContainer/MarginContainer/TextBoxBG/Components
	label_comps.clear()
	label_comps.append_text("[color=black]" + comp_string + "[/color]")
	
	#Beschreibung des Items
	var label_descr = $Background/VBoxContainer/MarginContainer/TextBoxBG/Description
	label_descr.clear()
	label_descr.append_text("[color=black][font_size=36][i]" + sender.get_descr() +
		"[/i][/font_size][/color]")
	pass
