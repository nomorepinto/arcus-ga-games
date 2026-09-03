extends Control

@onready var vbox = $VBoxContainer
@onready var difficulty_option = $VBoxContainer/OptionButton
@onready var play_button = $VBoxContainer/Button 

func _ready():
	# --- 1. YOUR ORIGINAL SETUP ---
	if difficulty_option:
		difficulty_option.clear()
		difficulty_option.add_item("Easy (Circle, Triangle, Square)", 0)
		difficulty_option.add_item("Medium (Mixed Shapes)", 1)
		difficulty_option.add_item("Hard (Complex & Rare)", 2)
		
	# Automatically connect the button signal through code!
	if play_button:
		# Added a quick check to prevent double-connecting the signal
		if not play_button.pressed.is_connected(_on_play_button_pressed):
			play_button.pressed.connect(_on_play_button_pressed)

	# --- 2. SAFE CONTAINER ANIMATION ---
	# Record the exact position the editor assigned to the container
	var target_pos = vbox.position
	
	# Move the entire container down slightly as a single unit
	vbox.position.y += 50
	
	# Make all items inside the container completely transparent
	for child in vbox.get_children():
		child.modulate.a = 0.0
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	# Slide the entire VBoxContainer up into its original place
	tween.tween_property(vbox, "position", target_pos, 1.2)
	
	# Create a cascading fade-in effect for the dropdown and play button
	var delay = 0.0
	for child in vbox.get_children():
		tween.tween_property(child, "modulate:a", 1.0, 1.0).set_delay(delay)
		delay += 0.2

func _on_play_button_pressed():
	# Save the dropdown choice (0 = Easy, 1 = Medium, 2 = Hard) to the GameManager
	if difficulty_option:
		GameManager.selected_difficulty = difficulty_option.get_selected_id()
		
	# Transition smoothly to the game!
	SceneTransition.change_scene("res://dalgona/scenes/main_dalgona.tscn")
