extends Area2D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_ammopill"):
		body.collect_ammopill()
		queue_free()   # remove pill after being collected
