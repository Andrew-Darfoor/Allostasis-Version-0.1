extends CharacterBody2D

@export var MAX_HEALTH: int = 3
var health: int = MAX_HEALTH
var is_dead: bool = false

@export var drift_speed: float = 40.0
@export var puff_speed: float = 120.0
@export var puff_interval: float = 4.0   # seconds between puffs
var puff_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ammo_pill_scene: PackedScene = preload("res://Scenes/Weapons/Ammopill.tscn")
@onready var health_pill_scene: PackedScene = preload("res://Scenes/Weapons/Healthpill.tscn")

func _ready():
	add_to_group("enemies")
	sprite.play("fluflyeridle")
	puff_timer = puff_interval

	# Collision setup (same as slime)
	collision_layer = 1 << 5   # enemy on layer 6
	collision_mask  = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 6) | (1 << 10)
func _physics_process(delta: float) -> void:
	if not get_parent().game_started:
		return
	# Drift slowly if not moving
	if velocity.length() < drift_speed:
		velocity = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() * drift_speed

	# Puff timer
	puff_timer -= delta
	if puff_timer <= 0.0:
		_puff()
		puff_timer = puff_interval

	# Movement with collisions
	move_and_slide()

func _puff():
	# Burst in random direction
	var dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	velocity = dir * puff_speed
	# Optional: play puff animation if you add one
	sprite.play("fluflyeridle")

# --- Damage handling ---
func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Fluflyer took damage, health =", health)

	if health <= 0:
		_die()
	else:
		sprite.stop()
		sprite.play("fluflyerhurt")
		sprite.animation_finished.connect(_on_hurt_finished, CONNECT_ONE_SHOT)

func _on_hurt_finished():
	if sprite.animation == "fluflyerhurt":
		sprite.play("fluflyeridle")

func _die() -> void:
	if is_dead:
		return
	is_dead = true

	print("Fluflyer dying now")

	# Disable collisions immediately
	set_collision_layer(0)
	set_collision_mask(0)
	remove_from_group("enemies")

	# Stop physics
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Play death animation
	sprite.stop()
	sprite.play("fluflyerdeath")

	# Free after animation finishes
	sprite.animation_finished.connect(_on_death_finished, CONNECT_ONE_SHOT)

func _on_death_finished():
	if sprite.animation == "fluflyerdeath":
		# Roll a random number between 0.0 and 1.0
		var roll = randf()
		if roll < 0.20:
			# 20% chance → spawn Ammopill
			var pill = ammo_pill_scene.instantiate()
			get_tree().get_current_scene().add_child(pill)
			pill.global_position = global_position
			print("Fluflyer dropped Ammopill")
		elif roll < 0.40:
			# Next 20% chance → spawn Healthpill
			var pill = health_pill_scene.instantiate()
			get_tree().get_current_scene().add_child(pill)
			pill.global_position = global_position
			print("Fluflyer dropped Healthpill")
		else:
			# 60% chance → nothing
			print("Fluflyer dropped nothing")

		queue_free()
