extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body): 
		if body.has_method("collect_pillcoin"):
			body.collect_pillcoin()
			queue_free()   # remove pill after being collected
