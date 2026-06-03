extends CharacterBody2D

@onready var dialogue_box = get_tree().root.get_node("Level1/GUI/DialogueBox")
@onready var prompt_label: Label = $PromptLabel
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var talk_zone: Area2D = $npcTalkzone   # Area2D, not CollisionShape2D

@export var dialogue_pages: Array[String] = [
	"Greetings, traveler. I am Dandril, take my weapon the AntibodyShot.",
	"It will serve you well—antibodies are the body’s first responders, so this weapon is fast and has a long range."
]

var player_in_range: bool = false

func _ready():
	talk_zone.body_entered.connect(_on_body_enter)
	talk_zone.body_exited.connect(_on_body_exit)
	prompt_label.hide()
	sprite.play("default")

func _on_body_enter(body):
	if body.is_in_group("player"):
		player_in_range = true
		prompt_label.show()

func _on_body_exit(body):
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.hide()
		dialogue_box.hide()
		sprite.play("default")

func _input(event):
	if not player_in_range:
		return

	if Input.is_action_just_pressed("talk"):
		if dialogue_box.visible:
			dialogue_box.advance_dialogue()   # go to next line
		else:
			dialogue_box.start_dialogue(dialogue_pages)   # start at line 0
		sprite.play("Talking")
