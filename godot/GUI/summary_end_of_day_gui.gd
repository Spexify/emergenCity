extends EMC_GUI
class_name EMC_SummaryEndOfDayGUI

const ACTION_LOG_UI = preload("res://GUI/action_log_ui.tscn")

const TIPS = [
	"Kümmer dich um deine Gesundheit, iss und trink etwas.",
	"Helfen deinen Nachbarn um Gesellschaftspunkte zu bekommen"
]

@export var _scoreboard: EMC_Scoreboard

@onready var score: RichTextLabel = $SummaryWindow/MarginContainer/VBC/PC/Score
@onready var logs: VBoxContainer = $SummaryWindow/MarginContainer/VBC/SC/Logs
@onready var tips: RichTextLabel = $SummaryWindow/MarginContainer/VBC/TextBox/Tips


## opens summary end of day GUI/makes visible
func open(history: Array[String]) -> void:
	clear()
	
	score.set_text("[center]" + str(_scoreboard.get_day_score()))
	var summary: Dictionary = _scoreboard.get_day_summary()
	for cat: EMC_Scoreboard.ScoreCat in summary.keys():
		var new_log_ui: EMC_Action_Log_UI = ACTION_LOG_UI.instantiate()
		new_log_ui.cat_name = EMC_Scoreboard.score_cat_to_text[cat]
		new_log_ui.score = summary[cat]
		new_log_ui.color = EMC_Scoreboard.score_cat_to_color[cat]
		logs.add_child(new_log_ui)
		
	tips.set_text(TIPS.pick_random())
		
	show()
	opened.emit()

func clear() -> void:
	for child: EMC_Action_Log_UI in logs.get_children():
		child.queue_free()

## closes summary end of day GUI/makes invisible
func close() -> void:
	hide()
	closed.emit(self)

func _on_continue_pressed() -> void:
	close()

func _ready() -> void:
	hide()
