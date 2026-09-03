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
@onready var death_sound = $DeathSound
@onready var fail_sound = $FailSound

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
	warning_label.hide()
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
	
	var score_tween = create_tween()
	score_tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.08)
	score_tween.tween_property(score_label, "scale", Vector2.ONE, 0.08)
	
	# Add new balls at specific thresholds
	if current_score >= next_milestone:
		num_of_balls += 1
		trigger_ball_warning()
		next_milestone *= num_of_balls

func trigger_ball_warning():
	# Show the warning
	warning_label.show()
	warning_label.modulate.a = 0.0
	warning_label.scale = Vector2(0.8, 0.8)
	warning_label.pivot_offset = warning_label.size / 2.0
	
	var warning_tween = create_tween().set_parallel(true)
	warning_tween.tween_property(warning_label, "modulate:a", 1.0, 0.2)
	warning_tween.tween_property(warning_label, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Wait for 2 seconds
	await get_tree().create_timer(2.0).timeout
	
	# Hide the warning
	var fade_out = create_tween()
	fade_out.tween_property(warning_label, "modulate:a", 0.0, 0.2)
	await fade_out.finished
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
	game_over_panel.modulate.a = 0.0
	game_over_panel.scale = Vector2(0.9, 0.9)
	game_over_panel.pivot_offset = game_over_panel.size / 2.0
	
	var panel_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	panel_tween.tween_property(game_over_panel, "modulate:a", 1.0, 0.4)
	panel_tween.tween_property(game_over_panel, "scale", Vector2.ONE, 0.4)
	
	death_sound.play()
	fail_sound.play()

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
