extends Area2D

@onready var dialogue_box = get_tree().root.get_node("Level1/GUI/DialogueBox")
@onready var prompt_label: Label = $PromptLabel

var dialogue_pages := [
	"The mucus of the trachea keeps germs out and slows them down.",
	"Normally, mucus is your body’s shield—it traps invaders before they reach the lungs.",
	"But these germs are so vicious they’ve possessed the mucus itself!",
	"It’s become some sort of Phlegm Slime…",
	"Be careful—what once protected you is now dangerous!"
]

var player_in_range: bool = false

func _ready():
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	prompt_label.hide()

func _on_body_enter(body):
	if body.is_in_group("player"):
		player_in_range = true
		prompt_label.show()

func _on_body_exit(body):
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.hide()
		dialogue_box.hide()

func _input(event):
	if not player_in_range:
		return
	if Input.is_action_just_pressed("talk"):
		if dialogue_box.visible:
			dialogue_box.advance_dialogue()
		else:
			dialogue_box.start_dialogue(dialogue_pages)
