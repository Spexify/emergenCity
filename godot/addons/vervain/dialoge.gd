extends Resource
class_name VRV_Dialogue

enum {
	TEXT,
	END,
	CHOICE,
	ACTORS,
	EFFECT
}

var data: Dictionary = { "Imports": ["util"], "Nodes": { "start": { "sequence": [{ "actors": [{ "name": "Avatar", "flip": false }] }], "Choice": ["one", "two"] }, "one": { "Prompt": "Hello There", "sequence": [{ "actors": [{ "name": "Avatar", "flip": false }, { "name": "Gerhard", "flip": true }] }, { "random": [{ "text": [{ "speaker": "Gerhard", "line": "Hi" }] }, { "text": [{ "speaker": "Gerhard", "line": "ello" }] }] }, { "text": [{ "speaker": "Gerhard", "line": "Wie gehts dir?" }, { "speaker": "Avatar", "line": "Gut" }] }, { "jump": "two" }] }, "two": { "Prompt": "Hallo Friedel", "Condition": [{ "state": "is_npcs_on_current_stage", "value": "Friedel" }, { "state": "is_state", "value": "WaterState.CLEAN" }], "sequence": [{ "actors": [{ "name": "Friedel", "flip": false }, { "name": "Avatar", "flip": true }] }, { "text": [{ "speaker": "Friedel", "line": "wuff" }, { "speaker": "Avatar", "line": "Süß!!!" }] }] } } }

@export var nodes: Dictionary
var current_actors: Array[String] = []
var current_node: Dictionary = {}
var current_sequence: Array[Dictionary] = []
var current_entry: int = 0

var _stage_mngr: EMC_StageMngr
var _checker: EMC_ActionConstraints
var _start_npc: String = ""

func _init() -> void:
	self.setup(data)
	
func setup(data: Dictionary) -> void:
	nodes = data.get("Nodes")

func set_api(p_stage_mngr: EMC_StageMngr, p_checker: EMC_ActionConstraints) -> void:
	_stage_mngr = p_stage_mngr
	_checker = p_checker

func is_empty() -> bool:
	return data.is_empty()

func check_start() -> bool:
	if nodes["start"].has("Conditions"):
		return _check_conditions(nodes["start"]["Conditions"])
	return true
	
func get_next() -> Array:
	if current_node.is_empty():
		_jump("start")
	
	if current_entry < current_sequence.size():
		match current_sequence[current_entry]:
			{"actors": var raw_actors}:
				var textures: Array[Texture2D]
				var actors: Array[String]
				var flip: Array[bool]
				for data: Dictionary in raw_actors:
					var portrait: Texture2D
					var name: String = data["name"] 
					if data["name"] == "@npc":
						name = _start_npc
					
					if name == "avatar":
						portrait = (load("res://assets/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png"))
					else:
						portrait = _stage_mngr.get_NPC(name).get_comp(EMC_NPC_Descr).get_portrait()
					#var portrait: Texture2D = load("res://assets/characters/portrait_" + data["name"] + ".png")
					actors.append(name)
					flip.append(data["flip"])
					textures.append(portrait)
				
				current_entry += 1
				return [VRV_Dialogue.ACTORS, textures, actors, flip]
			{"random": var opts}:
				var options: Array[Dictionary]
				options.assign(opts)
				
				options = options.filter(
					func (data: Dictionary) -> bool:
						if data.has("jump"):
							if nodes.get(data["jump"]).has("Conditions"):
								return _check_conditions(nodes.get(data["jump"])["Conditions"])
						return true)
				
				var choose: Dictionary = options.pick_random()
				current_node = {
					"sequence": [choose]
				}
				current_sequence.assign(current_node.get("sequence", []))
				current_entry = 0
				
				return get_next()
			{"text": var text}:
				current_entry += 1
				var eager: bool = current_node.has("Choice") and current_entry >= current_sequence.size()
				return [VRV_Dialogue.TEXT, text, eager]
			{"jump": var node_name}:
				_jump(node_name)
				return get_next()
			{"action": var action_name}:
				JsonMngr.get_action(action_name).execute()
				current_entry += 1
				return get_next()
	
	# After choice is executed after sequence operations as it always jumps
	if current_entry >= current_sequence.size() and current_node.has("Choice"):
		## Choices: [{"prompt": "Bla Bla", "id": "NODE_NAME", "icon": ""}] 
		var choices: Array[Dictionary]
		for node_name: String in current_node["Choice"]:
			var node: Dictionary = nodes.get(node_name, {})
			if node.has("Prompt"):
				if node.has("Condition") and not _check_conditions(node["Condition"]):
					continue
				choices.append({"id": node_name, "prompt": node.get("Prompt"), "icon": node.get("icon", "none")})
					
		if choices.size() > 1:
			return [VRV_Dialogue.CHOICE, choices]
		elif choices.size() == 1:
			_jump(choices[0]["id"])
			return [VRV_Dialogue.TEXT, [{"speaker": "Avatar", "line": choices[0]["prompt"]}], false]
	
	current_node = {}
	return [VRV_Dialogue.END]

func _check_conditions(conditions: Array) -> bool:
	for cond: Dictionary in conditions:
		var method_name: String = cond["method_name"]
		var params: Array = cond["params"]
		if not _checker.has_method(method_name):
			printerr("Methode: \"%s\" missing in action_costraints" % method_name)
			continue
		
		if not _checker.callv(method_name, params):
			return false
	return true

func _jump(node_name: String) -> void:
	current_node = nodes.get(node_name)
	current_sequence.assign(current_node.get("sequence", []))
	current_entry = 0

func choose(id: String) -> void:
	_jump(id)
