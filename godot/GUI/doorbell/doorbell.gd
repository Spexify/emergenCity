extends TextureButton
class_name EMC_DoorBell

signal rang(p_stage_change_ID: int)

const POS_NORMAL := Vector2(0, 20)
const POS_PRESSED := Vector2(0, 30)

var _stage_change_ID: int

########################################### PUBLIC METHODS #########################################
func setup(p_text: String, p_stage_change_ID: int) -> void:
	($RTL as RichTextLabel).text = "[center][i]" + p_text + "[/i][/center]"
	_stage_change_ID = p_stage_change_ID


########################################## PRIVATE METHODS #########################################
func _on_button_down() -> void:
	($RTL as RichTextLabel).position = POS_PRESSED


func _on_button_up() -> void:
	($RTL as RichTextLabel).position = POS_NORMAL


func _on_pressed() -> void:
	SoundMngr.play_sound("dingDong")
	#await $DingDongSFX.finished
	rang.emit(_stage_change_ID)
