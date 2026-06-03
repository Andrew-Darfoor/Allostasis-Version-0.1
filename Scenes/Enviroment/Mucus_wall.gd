extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
var destroyed: bool = false

func _ready():
	print("Wall layer:", collision_layer, "mask:", collision_mask)
	sprite.play("wallnormal")
	add_to_group("destructible_wall")
	# Ensure it's on layer 11 so Slash can see it (and Leuko collides with it)
	collision_layer = 1 << 10  # wall on layer 11
	collision_mask  = (1 << 0) | (1 << 5)   # listens for player + enemies

func take_damage(amount: int = 1) -> void:
	if destroyed:
		return
	destroyed = true
	sprite.play("walldestroyed")
	collision.disabled = true
	sprite.animation_finished.connect(_on_destroy_finished, CONNECT_ONE_SHOT)

func _on_destroy_finished():
	if sprite.animation == "walldestroyed":
		queue_free()
