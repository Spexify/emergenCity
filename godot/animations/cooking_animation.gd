extends Node2D


## The animation currently only supports up to 4 input items at fixed positions
func play(p_recipe: EMC_Recipe) -> void:
	var input_item_IDs := p_recipe.get_input_item_IDs()
	
	$PanelContainer/OutputItem.frame = p_recipe._output_item_ID
	$PanelContainer/InputItem1.frame = input_item_IDs[0]
	
	if input_item_IDs.size() > 1:
		$PanelContainer/InputItem2.frame = input_item_IDs[1]
		$PanelContainer/InputItem2.show()
	else:
		$PanelContainer/InputItem2.hide()
	
	if input_item_IDs.size() > 2:
		$PanelContainer/InputItem3.frame = input_item_IDs[2]
		$PanelContainer/InputItem3.show()
	else:
		$PanelContainer/InputItem3.hide()
	
	if input_item_IDs.size() > 3:
		$PanelContainer/InputItem4.frame = input_item_IDs[3]
		$PanelContainer/InputItem4.show()
	else:
		$PanelContainer/InputItem4.hide()
	
	show()
	$AnimationPlayer.play("fusing")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(1).timeout
	close()


func close() -> void:
	hide()


func _ready() -> void:
	hide()

