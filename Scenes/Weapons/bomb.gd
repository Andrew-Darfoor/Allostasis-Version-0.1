extends RigidBody2D   # Bomb arcs under gravity

@export var speed := 400

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D   # normal hitbox
@onready var shockwave: Area2D = $shockwave                         # explosion hitbox (Area2D)
@onready var shockwave_shape: CollisionShape2D = $shockwave/CollisionShape2D  # shape inside Area2D
@onready var kaboom: AudioStreamPlayer = $Kaboom

var direction := 1

func _ready():
	add_to_group("bombs")
	sprite_2d.play("bomb_idle")

	# Launch initial velocity (arc forward + upward)
	linear_velocity = Vector2(speed * direction, -300)

	# Enable contact monitoring so we can detect collisions
	contact_monitor = true
	max_contacts_reported = 4

	# --- Collision setup ---
	# Bomb: layer 4, mask = walls (2) + enemies (6)
	collision_layer = 1 << 3
	collision_mask = (1 << 1) | (1 << 5)

	# Shockwave: layer 5, mask = walls (2) + enemies (6)
	shockwave.collision_layer = 1 << 4
	shockwave.collision_mask = (1 << 1) | (1 << 5)
	shockwave.monitoring = false
	shockwave_shape.disabled = true   # keep shape disabled until explosion
	shockwave.body_entered.connect(_on_shockwave_body_entered)

func _integrate_forces(state):
	# Check collisions each physics frame
	if get_contact_count() > 0:
		_explode()

func _explode():
	kaboom.play()
	if sprite_2d.animation == "explosion":
		return  # already exploding

	# Stop movement completely so bomb doesn't slide through walls/floor
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity_scale = 0           # disable gravity
	freeze = true               # lock physics simulation during explosion

	# Play explosion animation
	sprite_2d.play("explosion")

	# Toggle hitboxes
	collision_shape.set_deferred("disabled", true)   # disable normal hitbox safely
	shockwave.monitoring = true                      # enable Area2D detection
	shockwave_shape.set_deferred("disabled", false)  # enable shockwave shape safely

	# Free bomb after animation finishes
	sprite_2d.animation_finished.connect(func():
		queue_free())

func _on_shockwave_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(3)   # or whatever damage value you want
