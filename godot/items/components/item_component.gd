extends Node
##[b]IMPLIZIT ABSTRAKTE KLASSE: Es ergibt keinen Sinn eine Instanz von dieser
##Oberklasse zu erstellen![/b] Bitte nutze die Komponenten die von dieser Klasse
##erben.[br]
##Desweiteren Nutzen alle Item-Komponenten die Konstruktor-func "_init()" mit 
##Parametern. D.h. dass bei der Erstellung nicht die Preloaded/Packed-Szene
##sondern new() verwendet werden soll, z.B.: [br]
##[code]var ic_food = EMC_IC_Food.new(<Wert an Nahrhaftigkeit>)[/code]
##
##Komponentenbasierte Zuordnung von Eigenschaften zu [EMC_Item]s.
##Motivation/Prinzip ist: Composition > Inheritence.
##Im Netz kann man sich dazu informieren, die Kurzfassung ist:
##Statt tiefer Vererbungsbäume und Mehrfachvererbung sollte man lieber
##"Komposition" nutzen, also die jeweiligen Unterobjekte als Attribute
##der Items realisieren.
##Dies ist eine Komponente.
class_name EMC_ItemComponent

#FYI: Inherits "name" property of Node
var _color: Color

static var COMP_SCNS : Dictionary = {}

########################################## PUBLIC METHODS ##########################################
func _init(p_name: String, p_color: Color = Color.BLACK) -> void:
	name = p_name
	_color = p_color


## Can be overwritten by subclasses
func get_name_with_values() -> String:
	return get_name()


##All relevant information are returned with an appropriate BBCode Tag,
## this way the formatting is directly applied to a  RichTextLabel
func get_colored_name_with_vals() -> String:
	if get_name_with_values() == "":
		return ""
	else:
		return "[color=" + _color.to_html(false) + "]" + get_name_with_values() + "[/color]"

## Returns a EMC_ItemComponent Child Object
## If the Component name is invalid return null
static func from_dict(data : Dictionary) -> EMC_ItemComponent:
	var comp_name : String = data.get("name")
	var comp_params : Variant = data.get("params")
	var comp_scn : Resource = COMP_SCNS.get(comp_name, null)
			
	if comp_scn != null:
		return comp_scn.new(comp_params)
	else:
		var tmp_scn : Resource = load("res://items/components/IC_" + comp_name + ".gd")
		
		if tmp_scn == null:
			printerr("Comp with name: " +comp_name + ", does not exist.")
			return null
			assert(tmp_scn != null)
		
		COMP_SCNS[comp_name] = tmp_scn
		return COMP_SCNS[comp_name].new(comp_params)

########################################## PRIVATE METHODS #########################################
