extends EMC_App

@onready var tree : Tree = $Tree
@export var warn_texture : Texture2D

func start() -> void:
	tree.clear()
	
	var _root : TreeItem = tree.create_item()
	
	var description : Dictionary = OverworldStatesMngr.get_description()
	for scenario_name : String in description:
		var scenario : TreeItem = tree.create_item(_root)
		scenario.set_text(0, scenario_name.get_extension())
		for desc : String in description[scenario_name]:
			if description[scenario_name][desc] is Dictionary:
				var child : TreeItem = tree.create_item(scenario)
				for state : String in description[scenario_name][desc]["states"]:
					var state_info : Array = OverworldStatesMngr.name_to_state[state.get_basename()]
					var x : int = state_info[0].get(state.get_extension()) * 64
					var y : int = state_info[1] * 64
					child.set_icon(0, warn_texture)
					child.set_icon_region(0, Rect2(x, y, 64, 64))
				child.set_text(0, description[scenario_name][desc]["desc"])
			else:
				var child : TreeItem = tree.create_item(scenario, 0)
				child.set_text(0, description[scenario_name][desc])
				child.set_custom_color(0, Color(1, 1, 0, 1))
	
	show()
