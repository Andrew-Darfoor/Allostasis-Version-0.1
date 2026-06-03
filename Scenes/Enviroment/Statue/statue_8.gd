extends Area2D

@onready var dialogue_box = get_tree().root.get_node("Level1/GUI/DialogueBox")
@onready var prompt_label: Label = $PromptLabel

var dialogue_pages := [
	"This legendary weapon launches powerful enzymes that can break down molecules",
	"The Enzyme Launcher will do 3 damage per hit it packs quite the punch and has further range than the Complement Cleaver",
	"But it runs on limited ammon the green pill you'e been collecting that's the ammo",
	"So use it sparingly"
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
