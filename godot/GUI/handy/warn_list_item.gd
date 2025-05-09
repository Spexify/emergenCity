extends Button

@onready var in_icon : TextureRect = $Margin/HBox/Icon
@onready var in_text : RichTextLabel= $Margin/HBox/Text
@onready var arrow : TextureRect = $Margin/HBox/Arrow

var _text : String
var _icon : Texture2D
var _arrow : bool

func setup(p_text : String, p_icon : Texture2D, p_arrow : bool = true) -> void:
	_text = p_text
	_icon = p_icon
	_arrow = p_arrow
	
func _ready() -> void:
	in_icon.set_texture(_icon)
	in_text.set_text(_text)
	arrow.set_visible(_arrow)
