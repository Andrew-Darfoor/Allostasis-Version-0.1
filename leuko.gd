extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -650.0
var last_facing_dir := 1   # +1 = right, -1 = left
var has_antibody := false
var can_shoot := true
var is_shooting: bool = false
var has_cleaver := false
var has_enzymelauncher := false
var equipped_weapon := "none"  # Options: "none", "antibody", "cleaver"
var can_launch_bomb: bool = true

@onready var sprite_2d = $AnimatedSprite2D
@onready var slash_area: Area2D = $Slash
@onready var slash_shape: CollisionShape2D = $Slash/Slash_forward
@onready var bullet_scene: PackedScene = preload("res://Scenes/Weapons/bullet.tscn")
@onready var shoot_point = $ShootPoint
@onready var bomb_scene: PackedScene = preload("res://Scenes/Weapons/bomb.tscn")
@onready var launch_point = $LaunchPoint
@export var bomb_cooldown := 0.7   # seconds between bomb throws
@onready var swoosh: AudioStreamPlayer = $Swoosh
@onready var beam: AudioStreamPlayer = $Beam
@onready var blast: AudioStreamPlayer = $Blast

# Flash config
@export var flash_color: Color = Color(1, 0, 0)
@export var flash_duration: float = 0.15
# Knockback config
@export var knockback_force: Vector2 = Vector2(400, -400)  # push back + small upward
# Reference to main collision shape (not slash)
@onready var main_collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox

@export var MAX_HEALTH: int = 3
var health: int = MAX_HEALTH
var is_dead: bool = false
var pillcoins: int = 0
var ammo: int = 0   # new ammo counter


func _ready():
	print("Leuko layer:", collision_layer, "mask:", collision_mask)
	sprite_2d.animation_finished.connect(_on_animation_finished)
	print("LaunchPoint: ", launch_point)
	slash_area.monitoring = false
	slash_shape.disabled = true

	# Slash should collide with enemies
	slash_area.collision_layer = 1 << 6        # e.g. player attack layer
	slash_area.collision_mask = (1 << 5) | (1 << 10)

	slash_area.body_entered.connect(_on_slash_body_entered)
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	collision_layer = 1 << 0                     # Leuko on layer 1
	collision_mask = (1 << 1) | (1 << 10)        # floors (layer 2) + walls (layer 11)
	
func _physics_process(delta: float) -> void:
	# Block all physics until the level signals that gameplay has started
	if not get_parent().game_started:
		return

	# Apply gravity
	velocity += get_gravity() * delta * -up_direction

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * -up_direction.y

	# Jump cancel (short hop)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.4

	# Horizontal movement
	var direction := Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * SPEED * 0.7
		velocity.x = clamp(direction * SPEED, -SPEED, SPEED)
		last_facing_dir = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, 18)

	move_and_slide()

	# Flip sprite to face movement direction
	sprite_2d.flip_h = (last_facing_dir == 1)
	
	# Flip ShootPoint / LaunchPoint / Slash position
	if last_facing_dir == -1:
		shoot_point.position.x = -abs(shoot_point.position.x)
		launch_point.position.x = -abs(launch_point.position.x)
		slash_shape.position.x = -abs(slash_shape.position.x)   # facing left
	else:
		shoot_point.position.x = abs(shoot_point.position.x)
		launch_point.position.x = abs(launch_point.position.x)
		slash_shape.position.x = abs(slash_shape.position.x)    # facing right
	
	# --- ANIMATION HANDLING ---
	if not is_shooting:
		if equipped_weapon == "cleaver":
			if not is_on_floor():
				sprite_2d.animation = "Leukocleaverjump"
			elif abs(velocity.x) > 1:
				sprite_2d.animation = "Leukocleaverwalk"
			else:
				sprite_2d.animation = "Leukocleaveridle"
		elif equipped_weapon == "antibody":
			if has_antibody:
				if not is_on_floor():
					sprite_2d.animation = "Leukoantibodyjump"
				elif abs(velocity.x) > 1:
					sprite_2d.animation = "Leukoantibodywalk"
				else:
					sprite_2d.animation = "Leukoantibodyidle"
		elif equipped_weapon == "enzymelauncher":
			if has_enzymelauncher:
				if not is_on_floor():
					sprite_2d.animation = "Leukolaunchjump"
				elif abs(velocity.x) > 1:
					sprite_2d.animation = "Leukolaunchwalk"
				else:
					sprite_2d.animation = "Leukolaunchidle"
		else: # unequipped
			if not is_on_floor():
				sprite_2d.animation = "Leukojump"
			elif abs(velocity.x) > 1:
				sprite_2d.animation = "Leukowalk"
			else:
				sprite_2d.animation = "Leukoidle"

		sprite_2d.play()



func _input(event):
	if event.is_action_pressed("fire"):
		if equipped_weapon == "cleaver":
			_handle_cleaver_slash()
		elif equipped_weapon == "antibody" and has_antibody:
			_handle_shoot()
		elif equipped_weapon == "enzymelauncher" and has_enzymelauncher:
			_handle_launch()
	if event.is_action_pressed("swap"):
		_swap_weapon()



func _handle_shoot():
	_shoot_bullet()
	beam.play()
	if not is_on_floor():
		return

	if sprite_2d.animation == "Leukoantibodyidle":
		is_shooting = true
		sprite_2d.play("Leukoantibodyshoot")
	elif sprite_2d.animation == "Leukoantibodyshoot":
		# Restart shoot animation if pressed again mid-shoot
		sprite_2d.stop()
		sprite_2d.play("Leukoantibodyshoot")
		

func _handle_cleaver_slash():
	is_shooting = true
	swoosh.play()
	# Turn on hitbox
	slash_area.monitoring = true
	slash_shape.set_deferred("disabled", false)

	if sprite_2d.animation in ["Leukocleaveridle", "Leukocleaverwalk"]:
		sprite_2d.play("Leukoslash")
	elif sprite_2d.animation == "Leukocleaverjump":
		sprite_2d.play("Leukojumpslash")

func _handle_launch():
	blast.play()
	if not can_launch_bomb:
		return   # still cooling down, ignore input

	if ammo <= 0:
		print("No ammo left! Cannot launch bomb.")
		return   # block firing when out of ammo

	# Consume ammo
	ammo -= 1
	print("Bomb launched, ammo remaining =", ammo)

	_launch_bomb()
	can_launch_bomb = false

	# Start cooldown timer
	var timer := Timer.new()
	timer.wait_time = bomb_cooldown
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(func():
		can_launch_bomb = true)

	if not is_on_floor():
		return

	if sprite_2d.animation == "Leukolaunchidle":
		is_shooting = true
		sprite_2d.play("Leukolaunching")
	elif sprite_2d.animation == "Leukolaunching":
		sprite_2d.stop()
		sprite_2d.play("Leukolaunching")


		
func _shoot_bullet() -> void:
	var bullet := bullet_scene.instantiate()
	bullet.direction = last_facing_dir

	# Add to active scene (avoids being paused/disabled under certain parents)
	get_tree().get_current_scene().add_child(bullet)

	# Offset forward so it doesn’t overlap the player or slash hitbox
	var offset := Vector2(24 * last_facing_dir, 0)
	bullet.global_position = shoot_point.global_position + offset

	print("Spawned bullet at: ", bullet.global_position, " dir=", bullet.direction)
	
func _launch_bomb():
	var bomb = bomb_scene.instantiate()
	bomb.direction = last_facing_dir
	get_tree().get_current_scene().add_child(bomb)
	bomb.global_position = launch_point.global_position



func _on_animation_finished():
	match sprite_2d.animation:
		"Leukoantibodyshoot":
			is_shooting = false
			# Return to antibody movement
			if not is_on_floor():
				sprite_2d.play("Leukoantibodyjump")
			elif abs(velocity.x) > 1:
				sprite_2d.play("Leukoantibodywalk")
			else:
				sprite_2d.play("Leukoantibodyidle")
		"Leukoslash", "Leukojumpslash":
			is_shooting = false
			slash_area.monitoring = false
			slash_shape.set_deferred("disabled", true)
			# Return to cleaver movement
			if not is_on_floor():
				sprite_2d.play("Leukocleaverjump")
			elif abs(velocity.x) > 1:
				sprite_2d.play("Leukocleaverwalk")
			else:
				sprite_2d.play("Leukocleaveridle")
		"Leukolaunching":
			is_shooting = false
			if not is_on_floor():
				sprite_2d.play("Leukolaunchjump")
			elif abs(velocity.x) > 1:
				sprite_2d.play("Leukolaunchwalk")
			else:
				sprite_2d.play("Leukolaunchidle")
		"Leukodeath":
			# When death animation finishes, reload the current scene
			get_tree().reload_current_scene()


func _swap_weapon():
	var options = []
	if has_antibody:
		options.append("antibody")
	if has_cleaver:
		options.append("cleaver")
	if has_enzymelauncher:
		options.append("enzymelauncher")
	options.append("none")

	var current_index = options.find(equipped_weapon)
	equipped_weapon = options[(current_index + 1) % options.size()]


func equip_cleaver():
	has_cleaver = true
	equipped_weapon = "cleaver"   # auto‑equip on pickup

func equip_antibody():
	has_antibody = true
	equipped_weapon = "antibody"  # auto‑equip on pickup
	
func equip_enzymelauncher():
	has_enzymelauncher = true
	equipped_weapon = "enzymelauncher"
	
func _on_slash_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(3)
	elif body.is_in_group("destructible_wall") and body.has_method("take_damage"):
		body.take_damage(1)
func _on_hitbox_body_entered(body: Node) -> void:
	if is_dead:
		return
	if body.is_in_group("enemies"):
		_take_damage(body)

func _take_damage(enemy: Node) -> void:
	health -= 1
	print("Leuko took damage, health =", health)

	# Flash red
	sprite_2d.self_modulate = flash_color
	await get_tree().create_timer(flash_duration).timeout
	sprite_2d.self_modulate = Color(1,1,1)

	# Knockback: push opposite of enemy’s position
	var dir = sign(global_position.x - enemy.global_position.x)
	velocity.x = knockback_force.x * dir
	velocity.y = knockback_force.y

	if health <= 0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	print("Leuko died")

	# Disable collisions
	$CollisionShape2D.disabled = true

	# Stop physics
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Play death animation instead of freeing immediately
	sprite_2d.play("Leukodeath")

func collect_pillcoin() -> void:
	pillcoins += 1
	print("Collected pillcoin, total =", pillcoins)

	# Every 3 pillcoins → regain 1 health (if not already max)
	if pillcoins % 3 == 0 and health < MAX_HEALTH:
		health += 1
		print("Leuko regained 1 HP! Health =", health)
		
func collect_ammopill() -> void:
	ammo += 3
	print("Collected Ammopill, ammo =", ammo)
