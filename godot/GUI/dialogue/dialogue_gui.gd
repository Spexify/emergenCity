class_name EMC_Dialogue
extends EMC_GUI

@onready var portraits : HBoxContainer = $Portraits
@onready var dialogue_box : RichTextLabel = $Margin/VSplitContainer/TextPanel/Box
@onready var talk_sound : AudioStreamPlayer = $TalkSound
@onready var skip : Button = $Margin/VSplitContainer/Margin/Skip
@onready var next : Button = $Margin/VSplitContainer/Margin/Next
@onready var vbc : VBoxContainer = $Margin/VSplitContainer/VBC
@onready var margin : MarginContainer = $Margin/VSplitContainer/Margin

#var _dialogue : Dictionary = {}
var _dialogue_mngr : EMC_DialogueMngr
var _stage_mngr : EMC_StageMngr
var regex := RegEx.new()

const _icon_list : Dictionary = {
	"happy" : preload("res://assets/GUI/icons/icon_statusbar_happiness.png"),
	"health" : preload("res://assets/GUI/icons/icon_statusbar_health.png"),
	"food" : preload("res://assets/GUI/icons/icon_statusbar_nutrition.png"),
	"water" : preload("res://assets/GUI/icons/icon_statusbar_hydration.png"),
}

func _init() -> void:
	regex.compile("\\[.*?\\]")

func setup(p_dialogue_mngr : EMC_DialogueMngr, p_stage_mngr : EMC_StageMngr) -> void:
	_dialogue_mngr = p_dialogue_mngr
	_stage_mngr = p_stage_mngr

func open(dialogue : Dictionary) -> void:
	if dialogue.has("stage_name"):
		dialogue = _dialogue_mngr.start_dialogue_headless(dialogue.get("stage_name"), dialogue.get("actor_name"))
	
	if dialogue.is_empty():
		opened.emit()
		close.call_deferred()
		return
		
	dialogue_box.clear()
	self.show()
	
	var actors : Array[String] 
	actors.assign(dialogue.get("actors"))
	_load_actors_display(actors)
	
	#_dialogue = dialogue
		
	opened.emit()
	start.call_deferred(dialogue)

func close() -> void:
	self.hide()
	closed.emit(self)

func start(dialogue : Dictionary) -> void:
	for button : Button in vbc.get_children():
		if button.pressed.is_connected(start):
			button.pressed.disconnect(start)
	
	if dialogue.is_empty():
		close()
		return
	
	_dialogue_mngr.update_cooldown(dialogue)
	_dialogue_mngr.execute_dialoge_consequences(dialogue)
	
	vbc.hide()
	margin.show()
	
	var actors : Array[String] 
	actors.assign(dialogue.get("actors", []))
	_load_actors_display(actors)
	
	var raw_text : Array[String]
	raw_text.assign(dialogue.get("text", []) as Array)
	#if raw_text.is_empty():
		#close()
		#return
	
	var converstation : Array[PackedStringArray] = []
	for line : String in raw_text:
		converstation.append(line.split("#"))
		
	var talk_effect : = EMC_RichTextTalkEffect.new()
	#dialogue_box.install_effect(talk_effect)
	var promise := EMC_Util.Promise.new([talk_effect.finished, skip.pressed], EMC_Util.Promise.signal_or_name)
	
	var ii : int = 0
	for pair in converstation:
		#print(pair[0].get_basename() + ":" + pair[1])
		for portrait : TextureRect in portraits.get_children():
			if portrait.name == pair[0].get_basename():
				portrait.self_modulate = Color(1.0, 1.0, 1.0)
				portrait.set_flip_h(pair[0].get_extension() == "r")
			else:
				portrait.self_modulate = Color(0.4, 0.4, 0.4)
				
		#dialogue_box.set_visible_ratio(0)
		
		skip.show()
		next.hide()
		
		dialogue_box.clear()
		dialogue_box.append_text(pair[0].get_basename().to_pascal_case() + ":")
		dialogue_box.newline()
		talk_effect.set_char_count(regex.sub(pair[1], "", true).length())
		if pair[0].get_basename() == "avatar" or pair[0] == "Erzähler":
			dialogue_box.push_customfx(talk_effect, {"speed" : 15.0, "pitch" : 1.0})
		else:
			var npc: EMC_NPC = _stage_mngr.get_NPC(pair[0].get_basename())
			var pitch: float = npc.get_comp(EMC_NPC_Conversation).get_pitch()
			dialogue_box.push_customfx(talk_effect, {"speed" : 15.0, "pitch" : pitch})
		dialogue_box.append_text(pair[1])
		dialogue_box.pop()

		await promise.complete
		
		#dialogue_box.custom_effects.erase(talk_effect)
		dialogue_box.clear()
		dialogue_box.append_text(pair[0].get_basename().to_pascal_case() + ":")
		dialogue_box.newline()
		dialogue_box.append_text(pair[1])
		#dialogue_box.install_effect(talk_effect)
		
		skip.hide()
		next.show()

		if( ii < converstation.size()-1 or dialogue.get("options", {}).is_empty() 
		or not dialogue.get("options", {}).values().any(func(dict : Variant) -> bool: return dict is Dictionary and dict.has("prompt"))):
			await next.pressed
		ii += 1
		
	var options : Dictionary = dialogue.get("options", {})
	if options.is_empty():
		close()
		return
	var dialogue_options := _dialogue_mngr.next_dialogue(options)
	if dialogue_options.is_empty():
		close()
		return
	
	if dialogue_options.size() == 1:
		if dialogue_options[0].has("prompt"):
			_dialogue_mngr.update_cooldown(dialogue_options[0])
			var tmp_dialogue : Dictionary = dialogue_options[0].duplicate(true) # NOTICE should maybe be false for cooldown to work on next dialogues
			(tmp_dialogue["text"] as Array[String]).insert(0, "avatar#" + tmp_dialogue.get("prompt"))
			start.call_deferred(tmp_dialogue)
			return
		else:
			start.call_deferred(dialogue_options[0])
			return
	
	vbc.show()
	margin.hide()
	
	dialogue_options.sort_custom(func (a: Dictionary, b: Dictionary) -> bool: return a.get("prompt").nocasecmp_to(b.get("prompt")) < 0)

	var i : int = 0
	for button : Button in vbc.get_children():
		if i < dialogue_options.size():
			button.pressed.connect(start.bind(dialogue_options[i]))
			button.set_text(dialogue_options[i].get("prompt"))
			button.set_button_icon(_icon_list.get(dialogue_options[i].get("icon", "none"), null))
			button.show()
		else:
			button.hide()
		i += 1
	
func _load_actors_display(actors : Array[String]) -> void:
	assert(actors.size() <= 3, "Dialogues currently only support up to three Actors!")
	
	for port : TextureRect in portraits.get_children():
		port.set_name("option")
	
	var i : int = 0
	for port : TextureRect in portraits.get_children():
		if i < actors.size():
			port.show()
			if actors[i].get_basename() == "avatar":
				port.set_texture(load("res://assets/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png"))
			elif actors[i].get_basename() == "":
				continue
			else:
				var portrait : Texture2D = \
					_stage_mngr.get_NPC(actors[i].get_basename()).get_comp(EMC_NPC_Descr).get_portrait()
				port.set_texture(portrait)
			port.set_name(actors[i].get_basename())
			port.set_flip_h(actors[i].get_extension() == "r")
		else:
			port.hide()
		i += 1
