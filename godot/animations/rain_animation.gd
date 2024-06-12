extends EMC_GUI

func open(irrelevant : Variant = null) -> void:
	show()
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(2).timeout
	close()

func close() -> void:
	hide()
	closed.emit(self)
	$GPUParticles2D.emitting = false

func _ready() -> void:
	close()
