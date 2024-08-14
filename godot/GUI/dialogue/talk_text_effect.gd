@tool
class_name EMC_RichTextTalkEffect
extends RichTextEffect

signal finished

var bbcode : String = "talk"
var _char_count : int = 0
var _index : int = 0

func set_char_count(value : int) -> void:
	_char_count = value
	_index = 0

func _process_custom_fx(char_fx : CharFXTransform) -> bool:
	var speed : float = char_fx.env.get("speed", 10.0)
	var pitch : float = char_fx.env.get("pitch", 0.0)
	
	char_fx.visible = false
	
	if char_fx.elapsed_time * speed >= char_fx.relative_index:
		char_fx.visible = true
		if _index < char_fx.relative_index:
			_index = char_fx.relative_index
			if not Engine.is_editor_hint():
				SoundMngr.play_sound("Talk", 0.0, pitch + sin(char_fx.range.x) * 0.2)
	
	if _index == _char_count-1:
		_index += 1
		(func()->void:finished.emit()).call_deferred()
		
	return true
