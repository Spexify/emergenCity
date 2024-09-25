extends EMC_App

@onready var item_list : EMC_Item_List = $Notifications/Margin/VBC/ItemList
@export var warn_texture : Texture2D
@onready var notifications : Control = $Notifications
@onready var description : Control = $Description
@onready var text : RichTextLabel = $Description/Infos/MarginContainer/Text



func _ready() -> void:
	item_list.item_clicked.connect(_on_item_clicked)

func start() -> void:
	description.hide()
	notifications.show()
	
	item_list.clear()

	var description : Dictionary = OverworldStatesMngr.get_description()
	for scenario_name : String in description:
		
		#var textures : Array[Texture2D] = []
		#for key : String in description[scenario_name]:
			#if description[scenario_name][key] is Dictionary:
				#for state : String in description[scenario_name][key]["states"]:
					#var state_info : Array = OverworldStatesMngr.name_to_state[state.get_basename()]
					#var x : int = state_info[0].get(state.get_extension()) * 64
					#var y : int = state_info[1] * 64
					#textures.append(EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64)))
					
		var icon_id : int = JsonMngr.scenarios.get(scenario_name.get_extension()).get("icon_id")
		var x : int = (icon_id % 4) * 64
		var y : int = int(icon_id / 4) * 64
		var icon : Texture2D = EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64))
		item_list.add_item([scenario_name.get_extension(), icon], scenario_name)
	
	if item_list.is_empty():
		item_list.add_item(["Aktuell Gibt es\nkeine Warn Hinweise", EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(2*64, 2*64, 64, 64)), false], "Nothing")
		
		#for desc : String in description[scenario_name]:
			#if description[scenario_name][desc] is Dictionary:
				#var child : TreeItem = tree.create_item(scenario)
				#for state : String in description[scenario_name][desc]["states"]:
					#var state_info : Array = OverworldStatesMngr.name_to_state[state.get_basename()]
					#var x : int = state_info[0].get(state.get_extension()) * 64
					#var y : int = state_info[1] * 64
					#child.set_icon(0, warn_texture)
					#child.set_icon_region(0, Rect2(x, y, 64, 64))
				#child.set_text(0, description[scenario_name][desc]["desc"])
			#else:
				#var child : TreeItem = tree.create_item(scenario, 0)
				#child.set_text(0, description[scenario_name][desc])
				#child.set_custom_color(0, Color(1, 1, 0, 1))
	
	show()
	
func back() -> bool:
	if description.visible:
		description.hide()
		notifications.show()
		return false
	return true
	
func _on_item_clicked(id : String) -> void:
	print("Pressed on: '" + id + "'")
	
	if id != "Nothing":
		notifications.hide()
		description.show()
		text.set_text(JsonMngr.scenarios.get(id.get_extension()).get("description"))
	

func _on_text_meta_clicked(meta : Variant) -> void:
	var url : String = meta as String
	if url == null:
		return
	
	# TODO Safety
	OS.shell_open(url)
