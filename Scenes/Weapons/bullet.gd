extends Area2D

@export var speed := 700
var direction := 1  # +1 = right, -1 = left

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	add_to_group("bullets")  # Add this line
	print("Bullet added to 'bullets' group")  # Debug
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)  # Add this line
	

	# Flip bullet sprite based on direction
	sprite_2d.flip_h = (direction == -1)

func _physics_process(delta):
	position.x += speed * delta * direction

	if position.x < -1000000 or position.x > get_viewport_rect().size.x + 1000000:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1)   # bullets always do 1 damage
	queue_free()

func _on_area_entered(_area):
	queue_free()
