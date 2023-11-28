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

#FYI: erbt "name" Attribut von Node
var _color: Color

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init(p_name: String, p_color: Color = Color.BLACK):
	name = p_name
	_color = p_color

#FYI: erbt "get_name()" Attribut von Node


#Kann bei Bedarf von Unterklassen überschrieben werden
func get_name_with_values() -> String:
	return get_name()


##Alle relevanten Informationen werden mit einem entsprechenden BBCode Tag als
##String geliefert, sodass man sie direkt in einem RichTextLabel verwenden kann.
func get_colored_name_with_vals() -> String:
	return "[color=" + _color.to_html(false) + "]" + get_name_with_values() + "[/color]"

#----------------------------------------- PRIVATE METHODS -----------------------------------------
