extends Control

signal dialogue_finished

@onready var body_text: RichTextLabel = $Panel/BodyText

var pages: Array = []
var page_index: int = 0

func start_dialogue(dialogue_pages: Array):
	pages = dialogue_pages
	page_index = 0
	show()
	_show_page(page_index)
	# Debug:
	print("Dialogue started. size=", pages.size(), " page_index=", page_index)

func _show_page(i: int):
	body_text.text = pages[i]
	# Debug:
	print("Showing page", i, ":", pages[i])

func advance_dialogue():
	if page_index < pages.size() - 1:
		page_index += 1
		_show_page(page_index)
	else:
		hide()
		emit_signal("dialogue_finished")
		print("Dialogue finished")

# Remove _input from DialogueBox entirelyt
