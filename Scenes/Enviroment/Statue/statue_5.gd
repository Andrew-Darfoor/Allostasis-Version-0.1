extends Area2D
@onready var dialogue_box = get_tree().root.get_node("Level1/GUI/DialogueBox")
var dialogue_pages := [
	"Watch out for those Ciliaspikes!",
	"Cilia are tiny hair-like structures that line the trachea and other airways.",
	"They beat in waves to sweep dust and germs out of the  lungs.",
	"they’re spiky because they are clogged or damaged cilia.",
	"Healthy cilia protect you, but broken ones can turn into obstacles!"
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
		if player_in_range:
			if dialogue_box.visible:
				dialogue_box.advance_dialogue()
			else:
				dialogue_box.start_dialogue(dialogue_pages)
