extends EMC_GUI
class_name EMC_BookGUI

class Book:
	var ID: IDs
	var title: String
	var content: Array[String]
	
	func _init(p_ID: int, p_title: String, p_content: Array[String]) -> void:
		ID = p_ID
		title = p_title
		content = p_content


enum IDs{
	DUMMY = 0,
	TUTORIAL = 1,
	HISTORY_OF_CRISES = 2,
	MODERN_CRISIS_PREVENTION = 3,
}

const MIN_PAGE := 1

var _all_books: Array[Book]
var _curr_book: Book = null
var _curr_page: int #Starts at 1, because it might be shown in the GUI in the future
var _curr_max_page: int

########################################## PUBLIC METHODS ##########################################
func _ready() -> void:
	hide()
	$PanelContainer/VBC/PageBG/PageContent.bbcode_enabled = true
	_all_books = JsonMngr.load_books()


func open(p_book_ID: IDs) -> void:
	_curr_book = _all_books[p_book_ID - 1] #ID = 0 isn't loaded
	_curr_page = 1
	_curr_max_page = _curr_book.content.size()
	set_title(_curr_book.title)
	set_curr_page_text()
	show()
	opened.emit()


func close() -> void:
	hide()
	closed.emit()


func set_title(p_title: String) -> void:
	$PanelContainer/VBC/Title.text = "[center]" + p_title + "[/center]"


########################################## PRIVATE METHODS #########################################
func _on_backward_btn_pressed() -> void:
	if (_curr_page - 1) >= MIN_PAGE:
		_curr_page -= 1
		set_curr_page_text()


func _on_back_btn_pressed() -> void:
	close()


func _on_forward_btn_pressed() -> void:
	if (_curr_page + 1) <= _curr_max_page:
		_curr_page += 1
		set_curr_page_text()


func set_curr_page_text() -> void:
	$PanelContainer/VBC/PageBG/PageContent.text = _curr_book.content[_curr_page - 1]
	$PanelContainer/VBC/ButtonBar/BackwardBtn.disabled = _curr_page == MIN_PAGE
	$PanelContainer/VBC/ButtonBar/ForwardBtn.disabled = _curr_page == _curr_max_page


func _on_page_content_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
