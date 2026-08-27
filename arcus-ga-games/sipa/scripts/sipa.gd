extends RigidBody2D

# We will emit this signal to tell the Main UI to increase the score
signal sipa_tapped

# The upward force applied when tapped. Negative Y goes up in Godot.
@export var min_kick_force: float = -550.0
@export var max_kick_force: float = -900.0
@export var side_force: float = 300.0 # How hard it kicks to L or R

@onready var sprite = $Sprite2D
@onready var tap_sfx = $TapSFX
@onready var impact_sfx = $ImpactSFX

var default_texture = preload("res://sipa/assets/default_ball.png")

func _ready():
	# This ensures the random number generator seed is unique every time
	randomize()
	
	# Explicitly add this ball to the "sipa" group so the DeathZone can track it!
	if not is_in_group("sipa"):
		add_to_group("sipa")
	
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Only rotate if the ball is actually moving fast enough to matter
	if linear_velocity.length() > 50.0:
		# Find the target angle based on movement direction (plus 90 deg offset for upward-facing sprite)
		var target_angle = linear_velocity.angle() + PI / 2
		
		# Instead of harsh snapping, calculate the shortest rotation difference
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		
		# Apply a gentle corrective torque or rotational velocity so it turns fluidly
		angular_velocity = angle_diff * 8.0

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	# Listen for a left mouse click or a mobile screen tap
	if event is InputEventScreenTouch:
		if event.is_pressed():
			kick_upward()

func kick_upward():
	# Reset BOTH X and Y velocities to 0 before kicking
	# This prevents the ball from rocketing sideways.
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0 
	
	# Randomize vertical kick power
	var current_kick_force = randf_range(min_kick_force, max_kick_force)
	
	# randi() % 3 generates a random integer: 0, 1, or 2
	var random_direction = randi() % 3
	var horizontal_kick = 0.0
	
	if random_direction == 0:
		horizontal_kick = -side_force # Go L
		tap_sfx.pitch_scale = 0.8
	elif random_direction == 2:
		horizontal_kick = side_force # Go R
		tap_sfx.pitch_scale = 1.2
	# If it is 1, horizontal_kick stays at 0.0 (UP)
	
	# Apply the force using our new random X value and our consistent Y value
	apply_impulse(Vector2(horizontal_kick, current_kick_force))
	
	# Let the rest of the game know we scored a tap.
	sipa_tapped.emit()
	
	# Map sound pitch strictly to the strength of the kick 
	# (Stronger kick = higher pitch relative to the force range)
	var force_ratio = remap(current_kick_force, min_kick_force, max_kick_force, 0.8, 1.3)
	tap_sfx.pitch_scale = force_ratio
	
	impact_sfx.pitch_scale = randf_range(0.9, 1.1)
	impact_sfx.play()
	
	tap_sfx.play()
	
	await get_tree().create_timer(2.0).timeout
	sprite.texture = default_texture

# Check if the ball hits the wall or another ball.
func _on_body_entered(body: Node):
	impact_sfx.pitch_scale = randf_range(0.9, 1.1)
	impact_sfx.play()
