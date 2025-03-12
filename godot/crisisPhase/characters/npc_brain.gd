extends Node
class_name EMC_NPC_Brain

@export var actions: Dictionary = {
	"idle": "noop",
	"stroll": "change_stage"
}

@export var sub_comps: Array[EMC_NPC_Idee]
@export var decide: EMC_NPC_Decide

@onready var npc : EMC_NPC = $".."

var _stage_mngr: EMC_StageMngr

func _init(data : Dictionary) -> void:
	actions = data.get("actions", {})	
	for key : String in actions:
		var res: Resource = Preloader.get_resource("res://util/action/" + actions[key]["type"] + "_action.gd")
		actions[key] = res.new(actions[key], self._get_comp_by_name)
		#
		#if typeof(actions[key]) == TYPE_DICTIONARY:
			#if actions[key].has("0"):
				#actions[key] = MultiAction.new(actions[key])
			#else:
				#actions[key] = Callable(self, actions[key].get("method")).bindv(actions[key].get("params"))
				#Action.new(actions[key].get("method"), actions[key].get("params"))
			
	var sub_comps_data: Dictionary = data.get("comps", {})
	var decide_data: Dictionary = data.get("decide", {})
	
	if decide_data.has("name"):
		var decide_class: Resource = load("res://crisisPhase/characters/npc_" + decide_data["name"] + ".gd")
		
		decide = decide_class.new(decide_data)
	else:
		print_debug("Failed to contruct decide comp.")
		decide = EMC_NPC_Decide.new()
	
	
	for comp_name: String in sub_comps_data:
		var comp_class: Resource = load("res://crisisPhase/characters/npc_" + comp_name + ".gd")
		var new_comp: Variant = comp_class.new(sub_comps_data[comp_name])
		if new_comp != null:
			sub_comps.append(new_comp)

func _get_comp_by_name(comp_name: String) -> Variant:
	if comp_name == "self":
		return self
	return npc.get_comp_by_name(comp_name)

func _ready() -> void:
	npc.add_comp(self)
	_stage_mngr = npc.get_stage_mngr()
	_stage_mngr.npc_act.connect(act)

	for sub: EMC_NPC_Idee in sub_comps:
		self.add_child(sub)
	
func act() -> void:
	var options: Array[String] = collect_options()
	
	var decision: String = decide.choose_option(options)
	
	print(npc.get_comp(EMC_NPC_Descr).get_npc_name() + ": " + decision)
	
	actions[decision].execute()
	#if len(decision) == 1:
		#var action : Variant  = actions.get(decision[0])
		#if has_method(action.method_name):
			#callv(action.method_name, action.params)
	#else :
		#if has_method(actions.get(decision[0])):
			#callv(actions.get(decision[0]), decision.slice(1))
	
func change_stage(stage_name: String, x: String = "", y: String = "") -> void:
	var position: Vector2 = Vector2(x.to_float(), y.to_float())
	if position == Vector2.ZERO:
		position = Vector2.INF
	
	var stage: EMC_NPC_Stage = npc.get_comp(EMC_NPC_Stage)
	stage.override_spawn(position)
	stage.change_stage(stage_name)

func coop(npc_name: String, action: String) -> void:
	var cooperation: EMC_NPC_Cooperation = _stage_mngr.get_NPC(npc_name).get_comp(EMC_NPC_Cooperation)
	
	action = action.replace("@", "#")
	
	cooperation.request_cooperation(action)

func noop(stuff: Variant) -> void:
	pass

func collect_options() -> Array[String]:
	var options: Array[String] = []
	for sub: EMC_NPC_Idee in sub_comps:
		options.append_array(sub.supply_actions())
	
	return options
