extends Area2D
@onready var dialogue_box = get_tree().root.get_node("Level1/GUI/DialogueBox")
var dialogue_pages := [
	"This statue honors the leukocytes that protect the trachea."
]

var player_in_range: bool = false
@onready var prompt_label: Label = $PromptLabel

func _ready():
	print("DialogueBox found:", dialogue_box)
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	prompt_label.hide()  # start hidden

func _on_body_enter(body):
	if body.is_in_group("player"):
		player_in_range = true
		print("Prompt should show")
		prompt_label.show()   # show "Press T"

func _on_body_exit(body):
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.hide()   # hide prompt
		dialogue_box.hide()   # hide dialogue when leaving statue

func _input(event):
	if event.is_action_pressed("talk"):
		print("Statue: T pressed, player_in_range =", player_in_range)
		if player_in_range:
			print("Statue: calling start_dialogue")
			dialogue_box.start_dialogue(dialogue_pages)
		else:
			print("Statue: not in range, no call")
