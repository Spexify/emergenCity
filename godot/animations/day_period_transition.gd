extends EMC_GUI
class_name EMC_DayPeriodTransition

const FADE_IN_ANIM := "fade_in"
const FADE_OUT_ANIM := "fade_out"
const AMPLITUDE = 200
const SPEED : float = 3.0

@onready var icon_prev_period : Sprite2D = $Icon_PrevPeriod
@onready var icon_next_period : Sprite2D = $Icon_NextPeriod
@onready var days : RichTextLabel = $RichTextLabel
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var ONE_PERIOD_RADIAN := PI / (EMC_DayMngr.DayPeriod.size() - 1)
var distance_factor := 1.0
var _MAX_TIME: float = 1.0/SPEED #+ _START_TIME
#@onready var _START_TIME: float = 1.0 + $AnimationPlayer.get_animation("fade_in").length
var _start_move_anim: bool = false
var _origin_pos: Vector2 = Vector2(300, 600) #get_viewport_rect().size / 2
var _time: float 
var _rad_offset: float


########################################## PUBLIC METHODS ##########################################
func open(p_curr_day: int, p_new_day_period: EMC_DayMngr.DayPeriod) -> void:
	days.text = "[center][color=white]" + "Tag" + " " + str(p_curr_day) + "[/color]"
	#_rad_offset = (1.0 * PI) + ((EMC_DayMngr.DayPeriod.size() - p_new_day_period) * 0.5 * PI)
	var period: EMC_DayMngr.DayPeriod
	
	if p_new_day_period == EMC_DayMngr.DayPeriod.MORNING:
		period = EMC_DayMngr.DayPeriod.EVENING
		distance_factor = 2
	else:
		period = p_new_day_period - 1
		distance_factor = 1
	icon_prev_period.position = _get_position_for_period(period)
	icon_prev_period.frame = period
	icon_prev_period.modulate = Color(icon_prev_period.modulate, 255)
	icon_next_period.frame = p_new_day_period
	icon_next_period.modulate = Color(icon_next_period.modulate, 0)
	show()
	Global.get_tree().paused = true
	animation_player.play(FADE_IN_ANIM)

func close() -> void:
	hide()
	closed.emit(self)

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	($Marker_Morning as Sprite2D).position = _get_position_for_period(EMC_DayMngr.DayPeriod.MORNING)
	($Marker_Noon as Sprite2D).position = _get_position_for_period(EMC_DayMngr.DayPeriod.NOON)
	($Marker_Evening as Sprite2D).position = _get_position_for_period(EMC_DayMngr.DayPeriod.EVENING)
	hide()


## 
func _get_position_for_period(p_day_period: EMC_DayMngr.DayPeriod) -> Vector2:
	var res: Vector2 = Vector2(0, 0)
	#var pos_index := EMC_DayMngr.DayPeriod.size() - p_day_period - 1
	_rad_offset = ONE_PERIOD_RADIAN * (EMC_DayMngr.DayPeriod.size() - 1) - \
		(ONE_PERIOD_RADIAN * p_day_period) 
	
	res.x = _origin_pos.x + cos(_rad_offset) * AMPLITUDE 
	#Minus, because y-origin is top left, not bottom left corner:
	res.y = _origin_pos.y - sin(_rad_offset) * AMPLITUDE
	return res


func _process(delta: float) -> void:
	_time += delta
	
	if _start_move_anim: #_time > _START_TIME: 
		#Position
		var curr_rad_progress := _time * SPEED * ONE_PERIOD_RADIAN * distance_factor
		var rad := _rad_offset - curr_rad_progress
		icon_prev_period.position.x = _origin_pos.x + cos(rad) * AMPLITUDE
		icon_prev_period.position.y = _origin_pos.y - sin(rad) * AMPLITUDE
		icon_next_period.position = icon_prev_period.position
		#Transparency
		var progress_percentage: float = _time / _MAX_TIME
		icon_prev_period.modulate = Color(icon_prev_period.modulate, 1.0 - 1.0 * progress_percentage)
		icon_next_period.modulate = Color(icon_next_period.modulate, 1.0 * progress_percentage)
		
		
		if _time > _MAX_TIME: #Stop playing animation
			_start_move_anim = false
			await Global.get_tree().create_timer(0.3).timeout #wait shortly
			animation_player.play(FADE_OUT_ANIM)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == FADE_IN_ANIM:
		_start_move_anim = true
		_time = 0 #Time has to be 0 when its started, for the sin/cos values to be right!
	elif anim_name == FADE_OUT_ANIM:
		Global.get_tree().paused = false
		close()
