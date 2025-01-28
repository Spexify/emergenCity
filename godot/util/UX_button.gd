extends Button
## A more responsive Button for a better UX (User experience)
## Ideally this should be made into a custom node:
## See https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html 
## for details

func _on_button_down() -> void:
	pivot_offset = size / 2
	scale = Vector2(0.9, 0.9)


func _on_button_up() -> void:
	pivot_offset = size / 2
	scale = Vector2(1.0, 1.0)
