@tool
extends Script
class_name VRV_Dialoge_Parser

static var regex := RegEx.new()

# Utility function to trim and ignore empty lines
static func _clean_lines(script: String) -> Array[String]:
	var lines: PackedStringArray = script.split("\n")
	var result: Array[String] = []
	for line: String in lines:
		var trimmed: String = line.strip_edges()
		if trimmed != "":
			result.append(trimmed)
	return result

# Utiliy function to extract releanvant data of RegExMatch
static func _extract_info(matche: RegExMatch) -> Array:
	var section: Dictionary = matche.get_names()
		
	assert(section.has("directive"))
	var directive: String = matche.get_string("directive")
	
	var list_params: PackedStringArray
	var inline_params: PackedStringArray
	if section.has("in"):
		inline_params = matche.get_string("in").split(" ", false)
	elif section.has("out"):
		list_params = matche.get_string("out").split("\n", false)
		
	return [directive, inline_params, list_params]

# Parsing sequance directives
static func parse_sequence(directive: String, inline_params: PackedStringArray, list_params: PackedStringArray) -> Dictionary:
	match directive:
		"text":
			var text: Array[Dictionary]
			if not inline_params.is_empty():
				var param: Array = " ".join(inline_params).split(":", false)
				var speaker: String = param[0]
				var line: String = param[1]
				text.append({"speaker": speaker, "line": line})
			elif not list_params.is_empty():
				for raw_param: String in list_params:
					var param: Array = raw_param.split(":", false)
					var speaker: String = param[0]
					var line: String = param[1]
					text.append({"speaker": speaker, "line": line})
			
			return {"text": text}
		"jump":
			if not inline_params.is_empty():
				return {"jump": inline_params[0]}
			elif not list_params.is_empty():
				return {"jump": list_params[0]}
		"random":
			if not list_params.is_empty():
				
				var indent_script: Array[String]
				var param_string: String = "\n".join(list_params)
				indent_script.assign(Array(param_string.split("\n-", false)).map(func (s: String) -> String: return s.strip_edges()))
				
				var code: Array[Dictionary]
				for line_script: String in indent_script:
					var matche: RegExMatch = regex.search(line_script)
					if not matche == null:
						var info: Array = _extract_info(matche)
						var strip_list: PackedStringArray = PackedStringArray(Array(info[2]).map(func (s: String) -> String: return s.strip_edges()))
						code.append(parse_sequence(info[0], info[1], strip_list))
						
				return {"random": code}
		"actors": 
				var actors: Array[Dictionary] = []
				if not inline_params.is_empty():
					for param: String in inline_params:
						var data: Array[String]
						data.assign(param.split(".", false))
						var name: String = data[0]
						var flip: bool = false
						if data.size() > 1:
							flip = data[1] == "t"
						actors.append({"name": name, "flip": flip})
				elif not list_params.is_empty():
					for param: String in list_params:
						var data: PackedStringArray = param.split(" ", false)
						var name: String = data[0]
						var flip: bool = false
						if data.size() > 1:
							flip = data[1] == "t"
						actors.append({"name": name, "flip": flip})
					
				return {"actors": actors}
		"action":
			if not inline_params.is_empty():
				var data: Dictionary
				var raw_name := inline_params[0].split(".")
				data["system"] = raw_name[0]
				data["method"] = raw_name[1]
				data["params"] = inline_params.slice(1)
				data["type"] = "single"
				
				var action := EMC_Action.load_action(data)
				return {"action": action}
			if not list_params.is_empty():
				if list_params.size() == 1:
					var data: Dictionary
					var raw_name := list_params[0].split(".")
					data["system"] = raw_name[0]
					data["method"] = raw_name[1]
					
					var raw_params = "[" + " ".join(list_params.slice(1)) + "]"
					var json := JSON.new()
					var error := json.parse(raw_params)
					if error != OK or typeof(json.data) != TYPE_ARRAY:
						print("JSON Parse Error: ", json.get_error_message(), "in ", raw_params)
						return {}
					
					data["params"] = json.data
					data["type"] = "single"
					
					var action := EMC_Action.load_action(data)
					return {"action": action}
				else:
					var multi_data: Dictionary
					multi_data["acc"] = "array"
					multi_data["type"] = "multi"
					multi_data["actions"] = []
					for entry: String in list_params:
						var data: Dictionary
						var raw_var := entry.substr(2).split("=", false)
						if raw_var.size() > 1:
							data["as"] = raw_var[0]
						var raw_line := raw_var[-1].split(" ", false)
						var raw_name := raw_line[0].split(".", false)
						data["system"] = raw_name[0]
						data["method"] = raw_name[1]
						var raw_params = "[" + ", ".join(raw_line.slice(1)) + "]"
						
						var json := JSON.new()
						var error := json.parse(raw_params)
						if error != OK or typeof(json.data) != TYPE_ARRAY:
							print("JSON Parse Error: ", json.get_error_message(), "in ", raw_params)
							continue
						
						#print(raw_params)
						data["params"] = json.data
						data["type"] = "single"
						
						multi_data["actions"].append(data)
					
					var multi_action := EMC_Action.load_action(multi_data)
					return {"action": multi_action}
		"if":
			return {"if": "some"}
		"than":
			return {"than": "some"}
		"else":
			return {"else": "some"}
	
	return {}

static func parse_dialogue(script: String) -> VRV_Dialogue:
	regex.compile("\\[(?<directive>\\w+)\\](?:(?: (?<in>.+))?(?<out>(?:\\n[(?:\\- )\\t].+)+|(?:\\n[^\\[\\n]+)*))")
	
	var lines: Array[String] = _clean_lines(script)
	var data: Dictionary = {
		"Imports": [],
		"Nodes": {},
	}

	var matches: Array[RegExMatch] = regex.search_all(script)
	var i: int = 0
	var current_node: Dictionary
	while i < len(matches):
		var directive: String
		var inline_params: PackedStringArray
		var list_params: PackedStringArray
		
		var info: Array = _extract_info(matches[i])
		directive = info[0]
		inline_params = info[1]
		list_params = info[2]
		
		
		match directive:
			"Import":
				if not inline_params.is_empty():
					data["Imports"].append_array(inline_params)
				elif not list_params.is_empty():
					data["Imports"].append_array(list_params)
			"Node":
				var node_name: String
				if not inline_params.is_empty():
					node_name = inline_params[0]
				elif not list_params.is_empty():
					node_name = list_params[0]
				
				data["Nodes"][node_name] = {}
				current_node = data["Nodes"][node_name]
				
			"Prompt":
				if not inline_params.is_empty():
					current_node["Prompt"] = " ".join(inline_params)
				elif not list_params.is_empty():
					current_node["Prompt"] = list_params[0]
					
			"Condition":
				if not inline_params.is_empty():
					current_node["Condition"] = [{"method_name": inline_params[0], "params": inline_params.slice(1)}]
				elif not list_params.is_empty():
					current_node["Condition"] = []
					for raw_param: String in list_params:
						var param: PackedStringArray = raw_param.split(" ", false)
						current_node["Condition"].append({"method_name": param[0], "params": param.slice(1)})
						
			"Choice":
				if not list_params.is_empty():
					var choices: Array[String]
					choices.assign(Array(list_params).map(func (param: String) -> String: return param.right(-2)))
				
					current_node["Choice"] = choices
			"End":
				var dialoge: VRV_Dialogue = VRV_Dialogue.new()
				dialoge.setup(data)
				return dialoge
			_:
				if not current_node.has("sequence"):
					current_node["sequence"] = []
				
				current_node["sequence"].append(parse_sequence(directive, inline_params, list_params))
	
		i += 1
	
	var dialoge: VRV_Dialogue = VRV_Dialogue.new()
	dialoge.setup(data)
	return dialoge

	#var parsed: Dictionary = parse_dialogue("""
#[Import] util
#[Node] start
#[actors]
#Avatar
#[Choice]
#- one
#- two
#
#[Node] one
#[Prompt] Hello There
#[actors] Avatar Gerhard.t
#[random]
#- [text] Gerhard:Hi
#- [text] Gerhard:ello
#[text]
#Gerhard:Wie gehts dir?
#Avatar:Gut
#[jump] two
#
#[Node] two
#[Prompt] Hallo Friedel
#[Condition]
#is_npcs_on_current_stage Friedel
#is_state WaterState.CLEAN
#[actors] Friedel Avatar.t
#[text]
#Friedel:wuff
#Avatar:Süß!!!
#
#[End]""").data
#
	#print(parsed)
