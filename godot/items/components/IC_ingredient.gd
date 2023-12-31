extends EMC_ItemComponent
## Wird hauptsächlich verwendet um dem Spieler über die Oberfläche die Information
## an die Hand zu geben, dass man das Item auch auf irgendeine Art kochen kann.
##
## TODO: Ggf. doch überflüssig und kann gelöscht werden...
## Entscheidung ist eine Mischung aus Tech, Gameplay und UX Verantwortlichkeit.
class_name EMC_IC_Ingredient

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init() -> void:
	super("Zutat", Color.CORAL)

#----------------------------------------- PRIVATE METHODS -----------------------------------------
