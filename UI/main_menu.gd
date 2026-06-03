extends Node2D

var button_type = null

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_start_pressed() -> void:
	button_type = "Start"
	$Fade_transition.show()
	$Fade_transition/Fade_timer.start()
	$Fade_transition/AnimationPlayer.play("fade_in")

func _on_controls_pressed() -> void:
	button_type = "Controls"
	$Fade_transition.show()
	$Fade_transition/Fade_timer.start()
	$Fade_transition/AnimationPlayer.play("fade_in")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_fade_timer_timeout() -> void:
	if button_type == "Start" :
		get_tree().change_scene_to_file("res://Levels/level_1.tscn")
	elif button_type == "Controls":
		get_tree().change_scene_to_file("res://UI/controls_menu.tscn")
