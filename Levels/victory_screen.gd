extends Control

@onready var label: Label = $Panel/Label

func _ready():
	hide()  # start hidden

func show_victory():
	get_tree().paused = true
	show()
