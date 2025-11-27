extends Resource
class_name VRV_Script

enum {
	TEXT,
	END,
	CHOICE,
	ACTORS,
	NODE,
	CONTENT,
	TITLE
}

var data: Dictionary = { "Imports": ["util"], "Nodes": { "start": { "sequence": [{ "actors": [{ "name": "Avatar", "flip": false }] }], "Choice": ["one", "two"] }, "one": { "Prompt": "Hello There", "sequence": [{ "actors": [{ "name": "Avatar", "flip": false }, { "name": "Gerhard", "flip": true }] }, { "random": [{ "text": [{ "speaker": "Gerhard", "line": "Hi" }] }, { "text": [{ "speaker": "Gerhard", "line": "ello" }] }] }, { "text": [{ "speaker": "Gerhard", "line": "Wie gehts dir?" }, { "speaker": "Avatar", "line": "Gut" }] }, { "jump": "two" }] }, "two": { "Prompt": "Hallo Friedel", "Condition": [{ "state": "is_npcs_on_current_stage", "value": "Friedel" }, { "state": "is_state", "value": "WaterState.CLEAN" }], "sequence": [{ "actors": [{ "name": "Friedel", "flip": false }, { "name": "Avatar", "flip": true }] }, { "text": [{ "speaker": "Friedel", "line": "wuff" }, { "speaker": "Avatar", "line": "Süß!!!" }] }] } } }

@export var nodes: Dictionary
var current_actors: Array[String] = []
var current_node: Dictionary = {}
var current_sequence: Array[Dictionary] = []
var current_entry: int = -1

var last_node: Dictionary = {}

var gsi: VRV_GSI

var _context: Dictionary

signal ended(context: Dictionary)

#func _init() -> void:
	#self.setup(data)
	
func get_meta_data() -> Dictionary:
	return nodes.get("meta", {})
	
func setup(data: Dictionary) -> void:
	nodes = data.get("Nodes")

func is_empty() -> bool:
	return data.is_empty()

func check_start() -> bool:
	if nodes["start"].has("Condition"):
		return nodes["start"]["Condition"].execute(gsi, _context)
	return true
	
func get_next() -> Array:
	if current_node.is_empty():
		_jump("start")
	
	## if Node changed
	if current_entry < 0:
		current_entry = 0
		if not last_node.is_empty() and last_node["type"] != current_node["type"]:
			return [VRV_Script.NODE, current_node["type"]]
	
	if current_entry < current_sequence.size():
		match current_sequence[current_entry]:
			
			{"content": var content}:
				return [VRV_Script.CONTENT, content]
				
			{"title": var title}:
				return [VRV_Script.TITLE, title]
			
			## actors: [{"name": NAME, "flip": BOOL}, ...]
			{"actors": var raw_actors}:
				var textures: Array[Texture2D]
				var actors: Array[String]
				var flip: Array[bool]
				
				for data: Dictionary in raw_actors:
					var portrait: Texture2D
					var name: String = data["name"] 
					if (data["name"] as String).begins_with("@"):
						name = resolve_variable(data["name"])
					
					if name == "avatar":
						portrait = gsi.call_method("get_avatar_portrait", [])
					else:
						portrait = gsi.call_method("get_npc_portrait", [name])
					
					#if name == "avatar":
						#portrait = (load("res://assets/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png"))
					#else:
						#portrait = _stage_mngr.get_NPC(name).get_comp(EMC_NPC_Descr).get_portrait()
						
					actors.append(name)
					flip.append(data["flip"])
					textures.append(portrait)
				
				current_entry += 1
				return [VRV_Script.ACTORS, textures, actors, flip]
			
			## random: [SEQUENCE, SEQUENCE]
			{"random": var opts}:
				var options: Array[Dictionary]
				options.assign(opts)
				
				options = options.filter(
					func (data: Dictionary) -> bool:
						if data.has("jump"):
							if nodes.get(data["jump"]).has("Condition"):
								return nodes.get(data["jump"])["Condition"].execute(gsi, _context)
						return true)
				
				var choose: Dictionary = options.pick_random()
				current_node["sequence"].insert(current_entry+1, choose)
				current_sequence.assign(current_node.get("sequence", []))
				current_entry += 1
				
				return get_next()
			
			## text: [{"speaker": NAME, "line": LINE}, ...]
			{"text": var text}:
				current_entry += 1
				for line: Dictionary in text:
					var name := resolve_variable(line["speaker"])
					line["speaker"] = name
					line["pitch"] = gsi.call_method("get_pitch", [name])
					#text["pitch"] = _stage_mngr.get_NPC(name).get_comp(EMC_NPC_Descr).get_pitch()
					## See change in Choice: maybe we wont need eagerness anymore
				var eager: bool = current_node.has("Choice") and current_entry >= current_sequence.size()
				return [VRV_Script.TEXT, text, eager]
			
			## jump: NODE_NAME
			{"jump": var raw_node_name}:
				var node_name := resolve_variable(raw_node_name)
				
				if not nodes.get(node_name).has("Condition"):
					_jump(node_name)
				elif nodes.get(node_name)["Condition"].execute(gsi, _context):
					_jump(node_name)
				else:
					current_entry += 1
				return get_next()
			
			## goto: NODE_NAME
			{"goto": var raw_node_name}:
				var node_name := resolve_variable(raw_node_name)
				_jump(node_name)
				return get_next()
			
			## set: [NAME, VALUE/ACTION]
			{"set": [var name, var raw_value]}:
				var value: Variant = raw_value
				if is_instance_of(raw_value, VRV_Action):
					var action : VRV_Action = raw_value
					value = action.execute(gsi, _context)
				
				_context[name] = value
				current_entry += 1
				return get_next()
			
			## action: ACTION
			{"action": var action}:
				#JsonMngr.get_action(action_name).execute()
				action.execute(gsi, _context)
				current_entry += 1
				return get_next()
			
			## match: [VALUE/VARIABLE/ACTION, {VALUE: SEQUENCE, VALUE: SEQUENCE, ...}]
			{"match": [var action, var options]}:
				var value: Variant = action.execute(gsi, _context)
				
				print(value)
				print(options.keys())
				
				var choose: Dictionary = options.get(value, {"jump": "end"})
				current_node["sequence"].insert(current_entry+1, choose)
				current_sequence.assign(current_node.get("sequence", []))
				current_entry += 1
				
				return get_next()
				
	# Choice is executed after sequence operations as it always jumps
	if current_entry >= current_sequence.size() and current_node.has("Choice"):
		## Choices: [{"prompt": "Bla Bla", "id": "NODE_NAME", "icon": ""}] 
		var choices: Array[Dictionary]
		for choice: Dictionary in current_node["Choice"]:
			var node: Dictionary = nodes.get(choice["id"], {})
			if node.has("Condition") and not node["Condition"].execute(gsi, _context):
				continue
			choices.append({"id": choice["id"], "prompt": choice["prompt"], "icon": node.get("icon", "none")})
		
		## VRV_Scrpt should also be used for other uis thus we can not make a dialouge speciic choice
		if choices.size() >= 1:
			return [VRV_Script.CHOICE, choices]
		#elif choices.size() == 1:
			#_jump(choices[0]["id"])
			#return [VRV_Script.TEXT, [{"speaker": "Avatar", "pitch": EMC_Avatar.PITCH, "line": choices[0]["prompt"]}], false]
	
	current_node = {}
	ended.emit(_context)
	return [VRV_Script.END]
	
func resolve_variable(raw: String) -> Variant:
	if raw.begins_with("@"):
		var result = _context.get(raw, null)
		assert(result != null, "Variable %s not found in context" % raw)
		return result
	return raw
	
#func _check_conditions(conditions: Array) -> bool:
	#for cond: Dictionary in conditions:
		#var method_name: String = cond["method_name"]
		#var params: Array = cond["params"]
		#if not gsi.has_method(method_name):
			#printerr("Methode: \"%s\" missing in action_costraints" % method_name)
			#continue
		#
		#return gsi.callv(method_name, params)
	#return true

func _jump(node_name: String) -> void:
	last_node = current_node
	current_node = nodes.get(node_name)
	current_sequence.assign(current_node.get("sequence", []))
	current_entry = -1

func choose(id: String) -> void:
	_jump(id)
