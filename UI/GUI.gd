extends CanvasLayer

@onready var player = $"../Leuko"

var game_started: bool = false

func _ready() -> void:
	# Start invisible
	visible = false

	# Connect to the same fade transition AnimationPlayer as Level.gd
	var fade_anim = get_parent().get_node("Fade_transition/AnimationPlayer")
	fade_anim.animation_finished.connect(_on_fade_finished)

func _on_fade_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		game_started = true
		visible = true   # Show GUI only after fade-out completes

func _process(delta: float) -> void:
	if not game_started:
		return   # Don't update labels until fade-out is finished

	# Update labels with Leuko's values
	$Coin_number.text = str(player.pillcoins)
	$Heart_number.text = str(player.health) + "/" + str(player.MAX_HEALTH)
	$Ammo_number.text = str(player.ammo)
