extends Node2D
class_name EMC_DayPeriodTransition

const FADE_IN_ANIM := "fade_in"
const FADE_OUT_ANIM := "fade_out"
const AMPLITUDE = 200
const SPEED : float = 3.0
var ONE_PERIOD_RADIAN := PI / (EMC_DayMngr.DayPeriod.size() - 1)
var distance_factor := 1.0
var _MAX_TIME: float = 1.0/SPEED #+ _START_TIME
#@onready var _START_TIME: float = 1.0 + $AnimationPlayer.get_animation("fade_in").length
var _start_move_anim: bool = false
var _origin_pos: Vector2 = Vector2(300, 600) #get_viewport_rect().size / 2
var _time: float 
var _rad_offset: float


########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	$Marker_Morning.position = _get_position_for_period(EMC_DayMngr.DayPeriod.MORNING)
	$Marker_Noon.position = _get_position_for_period(EMC_DayMngr.DayPeriod.NOON)
	$Marker_Evening.position = _get_position_for_period(EMC_DayMngr.DayPeriod.EVENING)
	hide()


func _open(p_new_day_period: EMC_DayMngr.DayPeriod) -> void:
	#_rad_offset = (1.0 * PI) + ((EMC_DayMngr.DayPeriod.size() - p_new_day_period) * 0.5 * PI)
	var period: EMC_DayMngr.DayPeriod
	
	if p_new_day_period == EMC_DayMngr.DayPeriod.MORNING:
		period = EMC_DayMngr.DayPeriod.EVENING
		distance_factor = 2
	else:
		period = p_new_day_period - 1
		distance_factor = 1
	$Icon_PrevPeriod.position = _get_position_for_period(period)
	$Icon_PrevPeriod.frame = period
	$Icon_PrevPeriod.modulate = Color($Icon_PrevPeriod.modulate, 255)
	$Icon_NextPeriod.frame = p_new_day_period
	$Icon_NextPeriod.modulate = Color($Icon_NextPeriod.modulate, 0)
	show()
	get_tree().paused = true
	$AnimationPlayer.play(FADE_IN_ANIM)


## 
func _get_position_for_period(p_day_period: EMC_DayMngr.DayPeriod) -> Vector2:
	var res: Vector2
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
		$Icon_PrevPeriod.position.x = _origin_pos.x + cos(rad) * AMPLITUDE
		$Icon_PrevPeriod.position.y = _origin_pos.y - sin(rad) * AMPLITUDE
		$Icon_NextPeriod.position = $Icon_PrevPeriod.position
		#Transparency
		var progress_percentage: float = _time / _MAX_TIME
		$Icon_PrevPeriod.modulate = Color($Icon_PrevPeriod.modulate, 255 - 255 * progress_percentage)
		$Icon_NextPeriod.modulate = Color($Icon_NextPeriod.modulate, 255 * progress_percentage)
		
		
		if _time > _MAX_TIME: #Stop playing animation
			_start_move_anim = false
			await get_tree().create_timer(0.3).timeout #wait shortly
			$AnimationPlayer.play(FADE_OUT_ANIM)


func _on_day_mngr_period_ended(p_new_period: EMC_DayMngr.DayPeriod) -> void:
	_open(p_new_period)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == FADE_IN_ANIM:
		_start_move_anim = true
		_time = 0 #Time has to be 0 when its started, for the sin/cos values to be right!
	elif anim_name == FADE_OUT_ANIM:
		get_tree().paused = false
		hide()


func _on_day_mngr_day_ended(p_curr_day: int) -> void:
	$RichTextLabel.text = "[center][color=white]Tag " + str(p_curr_day) + "[/color]"
