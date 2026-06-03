extends Area2D

func _ready():
	monitoring = true
	monitorable = true
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	# If Leuko touches the spike, damage him
	if body.has_method("_take_damage"):
		body._take_damage(self)
