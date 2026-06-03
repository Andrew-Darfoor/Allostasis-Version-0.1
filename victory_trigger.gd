extends Area2D

@onready var victory_screen = get_tree().root.get_node("Level1/GUI/VictoryScreen")

func _ready():
	body_entered.connect(_on_body_enter)

func _on_body_enter(body):
	if body.is_in_group("player"):
		# Check if Leuko has all 3 weapons
		if body.has_antibody and body.has_cleaver and body.has_enzymelauncher:
			victory_screen.show_victory()
