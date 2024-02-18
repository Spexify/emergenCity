extends Node2D
class_name EMC_DayPeriodTransition

const FADE_IN_ANIM := "fade_in"
const FADE_OUT_ANIM := "fade_out"
const AMPLITUDE = 200
@export var frequency := 0.5 * PI
#@onready var _START_TIME: float = 1.0 + $AnimationPlayer.get_animation("fade_in").length
var _start_move_anim: bool = false
var _MAX_TIME: float = 1.0 #+ _START_TIME
var _base_pos: Vector2 = Vector2(300, 600) #get_viewport_rect().size / 2
var _time: float 
var _rad_offset: float


func _ready() -> void:
	$Marker_Morning.position.x = _base_pos.x + cos(0.0 * PI) * AMPLITUDE
	$Marker_Morning.position.y = _base_pos.y - sin(0.0 * PI) * AMPLITUDE
	$Marker_Noon.position.x = _base_pos.x + cos(0.5 * PI) * AMPLITUDE
	$Marker_Noon.position.y = _base_pos.y - sin(0.5 * PI) * AMPLITUDE
	$Marker_Evening.position.x = _base_pos.x + cos(1.0 * PI) * AMPLITUDE
	$Marker_Evening.position.y = _base_pos.y - sin(1.0 * PI) * AMPLITUDE
	hide()


func _open(p_new_day_period: EMC_DayMngr.DayPeriod) -> void:
	_rad_offset = (-0.5 * PI) + (p_new_day_period * 0.5 * PI)
	$DayPeriodIcon.position.x = _base_pos.x + cos(_rad_offset) * AMPLITUDE
	$DayPeriodIcon.position.y = _base_pos.y - sin(_rad_offset) * AMPLITUDE
	show()
	get_tree().paused = true
	$AnimationPlayer.play(FADE_IN_ANIM)
	


func _process(delta: float) -> void:
	_time += delta
	
	if _start_move_anim: #_time > _START_TIME: 
		$DayPeriodIcon.position.x = _base_pos.x + cos(_rad_offset + _time * frequency) * AMPLITUDE
		$DayPeriodIcon.position.y = _base_pos.y - sin(_rad_offset + _time * frequency) * AMPLITUDE
		if _time > _MAX_TIME: #Stop playing animation
			_start_move_anim = false
			await get_tree().create_timer(1.0).timeout #wait a second
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
