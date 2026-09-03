extends RigidBody2D

signal sipa_tapped

@export var min_kick_force: float = -550.0
@export var max_kick_force: float = -900.0
@export var side_force: float = 300.0

@onready var sprite = $Sprite2D
@onready var tap_sfx = $TapSFX
@onready var impact_sfx = $ImpactSFX
@onready var scream_sfx = $ScreamSFX

var idle_texture = preload("res://sipa/assets/idle_beneball.png")
var clicked_texture = preload("res://sipa/assets/tap_beneball.png")

func _ready():
	randomize()
	if not is_in_group("sipa"):
		add_to_group("sipa")
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if linear_velocity.length() > 50.0:
		var target_angle = linear_velocity.angle() + PI / 2
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		angular_velocity = angle_diff * 8.0

func _input_event(viewport, event, shape_idx):
	if (event is InputEventScreenTouch and event.is_pressed()) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		kick_upward()

func kick_upward():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0 
	
	var current_kick_force = randf_range(min_kick_force, max_kick_force)
	var random_direction = randi() % 3
	var horizontal_kick = 0.0
	
	if random_direction == 0:
		horizontal_kick = -side_force 
	elif random_direction == 2:
		horizontal_kick = side_force 
	
	apply_impulse(Vector2(horizontal_kick, current_kick_force))
	sipa_tapped.emit()
	
	# Swap to screaming face and play scream sound
	sprite.texture = clicked_texture
	if scream_sfx:
		scream_sfx.pitch_scale = randf_range(0.9, 1.1)
		scream_sfx.play()
		
	# Revert back after a brief moment
	await get_tree().create_timer(0.4).timeout
	if sprite:
		sprite.texture = idle_texture

	tap_sfx.play()
	impact_sfx.play()

func _on_body_entered(body: Node):
	impact_sfx.pitch_scale = randf_range(0.9, 1.1)
	impact_sfx.play()
