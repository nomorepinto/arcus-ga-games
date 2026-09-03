extends Node2D

var current_score: int = 0
var is_game_over: bool = false # Tracks if the game has ended
var sipa_scene = preload("res://sipa/scenes/sipa.tscn")
var beneball_scene = preload("res://sipa/scenes/beneball.tscn")
var next_milestone: int = 15
var num_of_balls: int = 1

@onready var score_label = $HUD/ScoreLabel
@onready var game_over_panel = $HUD/GameOverPanel
@onready var final_score_label = $HUD/GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var name_input = $HUD/GameOverPanel/VBoxContainer/NameInput
@onready var submit_button = $HUD/GameOverPanel/VBoxContainer/SubmitButton
@onready var restart_button = $HUD/GameOverPanel/VBoxContainer/RestartButton
@onready var status_label = $HUD/GameOverPanel/VBoxContainer/StatusLabel
@onready var warning_label = $HUD/WarningLabel

func _ready():
	# Find the DeathZone and connect its body_entered signal
	$DeathZone.body_entered.connect(_on_death_zone_body_entered)
	
	# Connect the Sipa ball's tap signal so we can track the score
	$Sipa.sipa_tapped.connect(_on_sipa_tapped)
	
	# Connect button signals
	submit_button.pressed.connect(_on_submit_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Listen for the backend response from our updated Next.js Autoload
	NextjsClient.score_submitted.connect(_on_score_submitted)
	
	# Ensure the UI starts at 0
	game_over_panel.hide()
	score_label.text = str(current_score)

func spawn_new_ball():
	var chosen_scene
	if randf() < 0.067:
		chosen_scene = beneball_scene
	else:
		chosen_scene = sipa_scene
	var new_ball = chosen_scene.instantiate()
	
	# Position it at the top-center of the screen
	new_ball.position = Vector2(get_viewport_rect().size.x / 2, 50)
	
	# Add it to the game
	add_child(new_ball)
	
	# Connect its tap signal so it also adds to our score
	new_ball.sipa_tapped.connect(_on_sipa_tapped)

func _on_sipa_tapped():
	current_score += 1
	# Update the text on the screen. (str() converts the integer to text)
	score_label.text = str(current_score)
	
	# Add new balls at specific thresholds
	if current_score >= next_milestone:
		num_of_balls += 1
		trigger_ball_warning()
		next_milestone *= num_of_balls

func trigger_ball_warning():
	# Show the warning
	warning_label.show()
	
	# Wait for 2 seconds
	await get_tree().create_timer(2.0).timeout
	
	# Hide the warning
	warning_label.hide()
	
	# Only spawn the ball if they didn't die during the 2-second wait!
	if not is_game_over:
		spawn_new_ball()

func _on_death_zone_body_entered(body: Node2D):
	# Check if the object that fell into the zone is our Sipa ball
	if body.is_in_group("sipa"):
		trigger_game_over()

func trigger_game_over():
	is_game_over = true # Stop any pending balls from spawning
	
	# Find every node in the "sipa" group and turn off its physics/clicks
	for ball in get_tree().get_nodes_in_group("sipa"):
		ball.set_process_input(false) 
		ball.set_deferred("freeze", true)
	
	# Hide the live score and show the Game Over screen
	score_label.hide()
	final_score_label.text = "Final Score: " + str(current_score)
	game_over_panel.show()

func _on_restart_pressed():
	# This reloads the current scene, resetting the game entirely!
	get_tree().reload_current_scene()

func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://sipa/scenes/leaderboard_ui.tscn")

func _on_submit_pressed():
	if name_input.text.strip_edges() == "":
		status_label.text = "Please enter a name!"
		return
	
	submit_button.disabled = true
	status_label.text = "Submitting..."
	
	# Generate a simple unique ID for the SK using the current Unix timestamp
	var player_id = str(Time.get_unix_time_from_system())
	
	# Send to our Vercel API (via the AWSClient autoload)
	NextjsClient.submit_score("SIPA", player_id, name_input.text, float(current_score))

func _on_score_submitted(success: bool, message: String):
	if success:
		status_label.text = "Score Saved!"
	else:
		status_label.text = "Error: " + message
		submit_button.disabled = false
