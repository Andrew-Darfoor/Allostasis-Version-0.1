extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D

@export var idle_time: float = 2.5   # seconds to wait in idle/set states

func _ready():
	monitoring = false
	monitorable = true   # <-- important
	shape.disabled = true
	connect("body_entered", _on_body_entered)  # <-- important
	sprite.play("spikeidle")
	_start_cycle()

func _start_cycle():
	await get_tree().create_timer(idle_time).timeout
	_spike_up()

func _spike_up():
	sprite.play("spikeup")
	monitoring = true
	shape.disabled = false
	sprite.animation_finished.connect(_on_spike_up_finished, CONNECT_ONE_SHOT)

func _on_spike_up_finished():
	sprite.play("spikeset")
	await get_tree().create_timer(idle_time).timeout
	_spike_down()

func _spike_down():
	sprite.play("spikedown")
	monitoring = true
	shape.disabled = false
	sprite.animation_finished.connect(_on_spike_down_finished, CONNECT_ONE_SHOT)

func _on_spike_down_finished():
	monitoring = false
	shape.disabled = true
	sprite.play("spikeidle")
	_start_cycle()

func _on_body_entered(body: Node) -> void:
	print("Trap touched:", body)  # Debug
	if body.has_method("_take_damage"):
		body._take_damage(self)
