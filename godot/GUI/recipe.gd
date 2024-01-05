extends TextureButton
class_name EMC_Recipe
#


###Tupe-Klasse (alles public und keine Methoden)
## Anm. Micky: Wieso keine Methoden? Manche sinnvoll, s. unten
#
const ITEM_SCN : PackedScene = preload("res://items/item.tscn")

var inputItems: Array[EMC_Item.IDs]
var outputItem: EMC_Item.IDs

var _needs_water : bool
var _needs_heat : bool

func setup(p_inputItems : Array[EMC_Item.IDs], p_outputItem: EMC_Item.IDs, p_needs_water : bool, \
p_needs_heat : bool) -> void:
	inputItems = p_inputItems
	outputItem = p_outputItem
	_needs_water = p_needs_water
	_needs_heat = p_needs_heat
	var item : EMC_Item = ITEM_SCN.instantiate()
	item.setup(p_outputItem)
	$HBoxContainer/item.replace_by(item)
	$HBoxContainer/RichTextLabel.text = item.get_name()



###Konstruktor
##func init():
	##pass
#
## Idee: Verschiedene Dictionarys für die verschiedenen Rezeptarten.
## Key ist das zu kochende Gericht, Value ist zwei Arrays: Erster mit verbrauchten Materialien (IDs wo schon 
## existent, sonst erstmal Namen), zweiter mit unverbrauchbaren Hilfsmitteln. Fragen: Wie genau durchsuche 
## ich einen Dictionary beim Kochen? Und wie referenziere ich am besten Objekte/Gerichte/etc., mit Namen oder mit ID?
#
## Rezepte warmes Kochen
#var warm_cooking_dict: Dictionary = {
	#"Ravioli (warm)": [[3],[]],
	#"Nudeln": [[NOODLES_DRY, 1], []],
	#"Nudeln mit Soße": [[NOODLES_DRY, 1, PASTA_SAUCE_JAR], []]
	## etc. 
#}
#
## Rezepte kaltes Kochen
#var cold_cooking_dict: Dictionary = {
	#"Salat": [[VEGETABLE], []],
	#"Müsli": [[MILK, OATMEAL], []]
	## etc.
#}
#
#
## Funktion, die aus einem der Rezept-Dictionarys die Rezepte heraussucht, die momentan möglich sind; 
## d.h.: bekommt Inventar gegeben, überprüft welche Rezepte mit den dort vorhandenen Materialien und den vorhandenen
## Hilfsmitteln möglich sind, und gibt Array aller möglichen Rezepte zurück.
## Bedenke: Wenn Haus sauberes Wasser hat, muss Wasser nicht als Item im Inventar vorhanden sein.
#
#
