extends CharacterBody2D

@export var JUMP_FORCE: float = 380.0
@export var GRAVITY: float = 900.0
@export var HOP_INTERVAL: float = 1.5
@export var SPEED: float = 60.0
@export var MAX_HEALTH: int = 3

var direction: int = -1
var hop_timer: float = 0.0
var jumping: bool = false
var just_landed: bool = false
var health: int = MAX_HEALTH
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ammo_pill_scene: PackedScene = preload("res://Scenes/Weapons/Ammopill.tscn")
@onready var health_pill_scene: PackedScene = preload("res://Scenes/Weapons/Healthpill.tscn")
@onready var ledge_check: RayCast2D = $LedgeCheck

func _ready():
	hop_timer = HOP_INTERVAL
	sprite.play("slimeidle")

	collision_layer = 1 << 5   # enemy on layer 6
	collision_mask  = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 6) | (1 << 10)
	floor_snap_length = 6.0

	add_to_group("enemies")

	# Ray setup: enabled, diagonal forward+down so it "faces" jump direction
	ledge_check.enabled = true
	ledge_check.target_position = Vector2(8 * direction, 160)  # forward and down

func _physics_process(delta: float) -> void:
	if not get_parent().game_started:
		return

	velocity.y += GRAVITY * delta

	# Keep ray facing current jump direction every frame
	ledge_check.target_position.x = 8 * direction

	# --- Ledge detection ---
	if not ledge_check.is_colliding():
		direction *= -1
		sprite.flip_h = (direction < 0)
		ledge_check.target_position.x = 8 * direction

	# --- Hop logic ---
	hop_timer -= delta
	if hop_timer <= 0.0 and is_on_floor():
		velocity.y = -JUMP_FORCE
		jumping = true
		hop_timer = HOP_INTERVAL
		sprite.play("slimejumpup")
		sprite.flip_h = (direction < 0)
		ledge_check.target_position.x = 8 * direction

	# Move sideways while airborne
	velocity.x = direction * SPEED if not is_on_floor() else 0

	move_and_slide()

	# --- Animation handling ---
	if is_on_floor() and velocity.y >= 0.0:
		if jumping:
			jumping = false
			just_landed = true
			sprite.play("slimejumpland")
		elif not jumping and not just_landed:
			if sprite.animation != "slimeidle":
				sprite.play("slimeidle")

	if just_landed and not sprite.is_playing():
		just_landed = false
		sprite.play("slimeidle")

	if velocity.y < 0:
		if sprite.animation != "slimejumpup":
			sprite.play("slimejumpup")
	elif velocity.y > 0 and not is_on_floor():
		if sprite.animation != "slimejumpdown":
			sprite.play("slimejumpdown")

	if is_on_wall():
		direction *= -1
		sprite.flip_h = (direction < 0)
		ledge_check.target_position.x = 8 * direction

# --- Damage handling ---
func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Slime took damage, health =", health)

	if health <= 0:
		_die()
	else:
		sprite.stop()
		sprite.play("slimehurt")
		sprite.animation_finished.connect(_on_hurt_finished, CONNECT_ONE_SHOT)

func _on_hurt_finished():
	if sprite.animation == "slimehurt":
		if is_on_floor():
			sprite.play("slimeidle")
		elif velocity.y < 0:
			sprite.play("slimejumpup")
		elif velocity.y > 0:
			sprite.play("slimejumpdown")

func _die() -> void:
	if is_dead:
		return
	is_dead = true

	print("Slime dying now")

	set_collision_layer(0)
	set_collision_mask(0)
	remove_from_group("enemies")

	set_physics_process(false)
	velocity = Vector2.ZERO

	sprite.stop()
	sprite.play("slimedeath")

	sprite.animation_finished.connect(_on_death_finished, CONNECT_ONE_SHOT)

func _on_death_finished():
	if sprite.animation == "slimedeath":
		var roll = randf()
		if roll < 0.20:
			var pill = ammo_pill_scene.instantiate()
			get_tree().get_current_scene().add_child(pill)
			pill.global_position = global_position
			print("Phlegmslime dropped Ammopill")
		elif roll < 0.40:
			var pill = health_pill_scene.instantiate()
			get_tree().get_current_scene().add_child(pill)
			pill.global_position = global_position
			print("Phlegmslime dropped Healthpill")
		else:
			print("Phlegmslime dropped nothing")

		queue_free()
