extends Node2D

var game_started = false

func _ready() -> void:
	$Fade_transition/AnimationPlayer.play("fade_out")
	$Fade_transition/AnimationPlayer.animation_finished.connect(_on_fade_finished)

func _on_fade_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		game_started = true
		# Enable player movement, spawn enemies, start timers, etc.
