extends EMC_GUI
class_name EMC_EndGameGUI
## Improvement idea: Instead of having two almost identical copies "WinnerScreen" and "LoserScreen"
## just have one and change the contents... That's a lot better because with each copy there is, the
## amount of work you have to do when making changes doubles (and you might overlook/forget to make
## changes for both)

const LOSER_COIN_FACTOR : int = 40
const WON := "GEWONNEN"
const LOST := "VERLOREN"
const ACTION_LOG_UI = preload("res://GUI/action_log_ui.tscn")

@export var _scoreboard: EMC_Scoreboard

@onready var title: RichTextLabel = $SummaryWindow/MarginContainer/VBC/TitleSpacing/Title
@onready var logs: VBoxContainer = $SummaryWindow/MarginContainer/VBC/SC/Logs
@onready var score: RichTextLabel = $SummaryWindow/MarginContainer/VBC/PCScore/Score
@onready var e_coins: RichTextLabel = $SummaryWindow/MarginContainer/VBC/TextBox/ECoins

@onready var pc_status: PanelContainer = $SummaryWindow/MarginContainer/VBC/PCStatus
@onready var water: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Water
@onready var food: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Food
@onready var heart: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Heart
@onready var smile: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Smile

func _ready() -> void:
	hide()


## opens summary end of day GUI/makes visible
func open(p_history: Array, p_won : bool, _avatar : EMC_Avatar) -> void:
	if p_won:
		title.set_text(WON)
		
		#pc_status.hide()
	
	else:
		title.set_text(LOST)
		
		#pc_status.show()
		
		smile.set_value(_avatar.get_happiness_status())
		water.set_value(_avatar.get_hydration_status())
		food.set_value(_avatar.get_nutrition_status())
		heart.set_value(_avatar.get_health_status())
	
	clear()
	
	score.set_text("[center]" + str(_scoreboard.get_game_score()))
	var summary: Dictionary = _scoreboard.get_game_summary()
	for cat: EMC_Scoreboard.ScoreCat in summary.keys():
		var new_log_ui: EMC_Action_Log_UI = ACTION_LOG_UI.instantiate()
		new_log_ui.cat_name = EMC_Scoreboard.score_cat_to_text[cat]
		new_log_ui.score = summary[cat]
		new_log_ui.color = EMC_Scoreboard.score_cat_to_color[cat]
		logs.add_child(new_log_ui)
		
	var coins: int = _scoreboard.calculate_e_coins(p_won)
	e_coins.set_text("Du hast " + str(coins) + " [img]res://assets/GUI/icons/icon_ecoins.png[/img] erhalten")
	
	Global.add_e_coins(coins)
	
	show()
	opened.emit()

func clear() -> void:
	for child: EMC_Action_Log_UI in logs.get_children():
		child.queue_free()

## closes summary end of day GUI/makes invisible
func close() -> void:
	hide()
	closed.emit(self)


func _on_main_menu_pressed() -> void:
	Global.get_tree().paused = false
	Global.reset_state()
	Global.reset_inventory()
	Global.reset_upgrades_equipped()
	Global.save_game(false)
	Global.goto_scene(Global.MAIN_MENU_SCENE)
