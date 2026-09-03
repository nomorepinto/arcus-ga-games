extends Node2D

# 1. Difficulty & Shape Grouping
@export var easy_scenes: Array[PackedScene]
@export var medium_scenes: Array[PackedScene]
@export var hard_scenes: Array[PackedScene]
@export var rare_fractal_scene: PackedScene 

# --- Audio Files ---
@export var crack_sounds: Array[AudioStream] 
@export var fail_audio: AudioStream 
@export var cookie_success_audio: AudioStream 
@export var run_complete_audio: AudioStream 
@export var death_audio: AudioStream

# Difficulty Setting: 0 = Easy, 1 = Medium, 2 = Hard
@export var current_difficulty: int = 0 

# 2. Permanent Main Nodes
@onready var trace_line = $Line2D
@onready var camera = $Camera2D 
@onready var needle = $Needle
@onready var timer_label = $UI/TimerLabel
@onready var progress_label = $UI/ProgressLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var final_time_label = $UI/GameOverPanel/FinalTimeLabel
@onready var skip_button = $UI/SkipButton
@onready var start_hint = $StartHintLabel
@onready var background = $Background
@onready var crack_sound = $CrackSound 
@onready var name_input = $UI/GameOverPanel/NameInput
@onready var submit_button = $UI/GameOverPanel/SubmitButton
@onready var status_label = $UI/GameOverPanel/StatusLabel

# --- Dedicated Event Sound Nodes ---
@onready var fail_sound = $FailSound
@onready var death_sound = $DeathSound
@onready var success_sound = $SuccessSound
@onready var game_win_sound = $GameWinSound

# 3. Dynamic Shape Variables
var current_shape
var outer_bounds
var inner_bounds_list: Array = [] 
var master_line
var checkpoint
var start_point 

# 4. Game State & Run Variables
var is_tracing = false
var game_over = false
var reached_wand_tip = false
var is_transitioning = false
var last_played_scene: PackedScene = null
var just_skipped_fractal: bool = false
var time_since_last_crack: float = 0.0

# --- Timer & Progression Tracking ---
var cookies_completed_in_run: int = 0
var target_cookies_per_run: int = 3
var run_timer: float = 0.0
var timer_active: bool = false
var medium_playlist: Array[String] = []

func _ready():
	randomize() 
	current_difficulty = GameManager.selected_difficulty
		
	if needle:
		needle.hide()
		
	if game_over_panel:
		game_over_panel.hide()
		
	if skip_button:
		skip_button.hide()
		if not skip_button.pressed.is_connected(_on_skip_button_pressed):
			skip_button.pressed.connect(_on_skip_button_pressed)
		
	var play_again_btn = $UI/GameOverPanel/PlayButton
	if play_again_btn and not play_again_btn.pressed.is_connected(_on_play_again_button_pressed):
		play_again_btn.pressed.connect(_on_play_again_button_pressed)
		
	var main_menu_btn = $UI/GameOverPanel/MainMenu
	if main_menu_btn and not main_menu_btn.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_btn.pressed.connect(_on_main_menu_button_pressed)
	
	if submit_button and not submit_button.pressed.is_connected(_on_submit_pressed):
		submit_button.pressed.connect(_on_submit_pressed)
		
	NextjsClient.score_submitted.connect(_on_score_submitted)
	
	start_new_run()

func start_new_run():
	cookies_completed_in_run = 0
	run_timer = 0.0
	timer_active = true
	game_over = false
	is_transitioning = false
	last_played_scene = null
	just_skipped_fractal = false
	time_since_last_crack = 0.0
	
	if name_input:
		name_input.text = ""
		name_input.editable = true
	
	if submit_button:
		submit_button.disabled = false
	
	if status_label:
		status_label.text = ""
	
	if skip_button:
		skip_button.hide()
	
	if current_difficulty == 1:
		medium_playlist = ["easy", "easy", "hard"]
		medium_playlist.shuffle()
	
	if game_over_panel:
		game_over_panel.hide()
		
	if background:
		background.show() 
		background.modulate.a = 1.0
		
	spawn_next_shape_in_run()

func spawn_next_shape_in_run():
	if current_shape != null:
		current_shape.queue_free()
		
	if progress_label:
		progress_label.text = "Cookie: " + str(cookies_completed_in_run + 1) + " / " + str(target_cookies_per_run)
		
	var selected_scene = get_scene_for_difficulty()
	if selected_scene == null:
		push_error("ERROR: No valid shape scene found for current difficulty!")
		return
		
	if skip_button:
		if selected_scene == rare_fractal_scene:
			skip_button.show()
		else:
			skip_button.hide()

	current_shape = selected_scene.instantiate()
	add_child(current_shape)

	outer_bounds = current_shape.get_node_or_null("Sprite2D/Area2D/OuterBounds")
	master_line = current_shape.get_node_or_null("MasterLine")
	checkpoint = current_shape.get_node_or_null("Checkpoint") 
	start_point = current_shape.get_node_or_null("StartPoint") 

	if start_point != null and start_hint != null:
		start_hint.global_position = start_point.global_position
		start_hint.global_position.y -= 150 
		start_hint.global_position.x -= (start_hint.size.x / 2.0)
		start_hint.show()

	inner_bounds_list.clear()
	var area2d = current_shape.get_node_or_null("Sprite2D/Area2D")
	if area2d:
		for child in area2d.get_children():
			if child.name.begins_with("InnerBounds") and child is CollisionPolygon2D:
				inner_bounds_list.append(child)

	if master_line == null:
		push_error("CRITICAL ERROR: 'MasterLine' missing in ", current_shape.name)

	if "fractal" in current_shape.name.to_lower():
		trace_line.width = 4.0 
	else:
		trace_line.width = 10.0 

	trace_line.clear_points()
	trace_line.default_color = Color(0, 0, 0)
	reached_wand_tip = false

func get_scene_for_difficulty() -> PackedScene:
	var fractal_chance = 0.002 
	if current_difficulty == 2:
		fractal_chance = 0.05 
		
	if rare_fractal_scene != null and randf() < fractal_chance and not just_skipped_fractal:
		last_played_scene = rare_fractal_scene
		just_skipped_fractal = false
		return rare_fractal_scene

	just_skipped_fractal = false

	var pool_to_use: Array[PackedScene] = []
	
	match current_difficulty:
		0: 
			pool_to_use = easy_scenes
		1: 
			var index = cookies_completed_in_run if cookies_completed_in_run < 3 else 2
			var current_shape_type = medium_playlist[index]
			if current_shape_type == "easy":
				pool_to_use = easy_scenes
			else:
				pool_to_use = hard_scenes
		2: 
			pool_to_use = hard_scenes

	if pool_to_use.is_empty():
		pool_to_use = easy_scenes
		
	var chosen_scene = get_random_scene_from_pool(pool_to_use, last_played_scene)
	
	if chosen_scene == null and not pool_to_use.is_empty():
		chosen_scene = pool_to_use[0]

	last_played_scene = chosen_scene
	return chosen_scene

func get_random_scene_from_pool(pool: Array[PackedScene], scene_to_exclude: PackedScene) -> PackedScene:
	if pool.is_empty():
		return null
		
	var valid_scenes = pool.duplicate()
	if scene_to_exclude != null and scene_to_exclude in valid_scenes and valid_scenes.size() > 1:
		valid_scenes.erase(scene_to_exclude)
		
	return valid_scenes.pick_random()

func _process(delta: float):
	time_since_last_crack += delta
	
	if timer_active and not game_over:
		run_timer += delta
		if timer_label:
			timer_label.text = "Time: " + String.num(run_timer, 2) + "s"

func _unhandled_input(event):
	if game_over or is_transitioning:
		if event is InputEventScreenTouch and event.pressed:
			pass
		return

	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		if event.pressed:
			handle_trace_press(event.position)
		else:
			is_tracing = false
			if needle:
				needle.hide()
			check_win_condition()

	elif event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if is_tracing:
			handle_trace_drag(event.position)

func handle_trace_press(screen_pos: Vector2):
	var global_pos = get_global_touch_pos(screen_pos)
	
	if master_line != null:
		var start_snap = get_closest_on_stencil(global_pos)
		var point_count = trace_line.get_point_count()
		
		if point_count == 0 and start_point != null:
			if start_snap.distance_to(start_point.global_position) > 40.0:
				is_tracing = false
				if needle:
					needle.hide()
				return 

		if point_count > 0:
			var last_point = trace_line.get_point_position(point_count - 1)
			if start_snap.distance_to(last_point) > 150.0:
				trigger_loss()
				return
				
		is_tracing = true
		if needle:
			needle.show()
			needle.global_position = global_pos
			
		if start_hint != null:
			start_hint.hide()
			
		trace_line.add_point(start_snap)
		play_crack_sound()

func handle_trace_drag(screen_pos: Vector2):
	var global_pos = get_global_touch_pos(screen_pos)
	if needle:
		needle.global_position = global_pos
		
	if master_line != null:
		process_tracing(global_pos)

func get_global_touch_pos(screen_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_pos

func process_tracing(global_pos: Vector2):
	if outer_bounds != null:
		var local_outer = outer_bounds.to_local(global_pos)
		var inside_outer = Geometry2D.is_point_in_polygon(local_outer, outer_bounds.polygon)

		var inside_any_inner = false
		for inner in inner_bounds_list:
			var local_inner = inner.to_local(global_pos)
			if Geometry2D.is_point_in_polygon(local_inner, inner.polygon):
				inside_any_inner = true
				break 

		if not (inside_outer and not inside_any_inner):
			trigger_loss()
			return

	if checkpoint != null:
		if global_pos.distance_to(checkpoint.global_position) < 30.0:
			reached_wand_tip = true
	else:
		reached_wand_tip = true

	var snapped_point = get_closest_on_stencil(global_pos)

	if trace_line.get_point_count() > 0:
		var last_drawn_point = trace_line.get_point_position(trace_line.get_point_count() - 1)
		
		if last_drawn_point.distance_to(snapped_point) > 150.0:
			trigger_loss()
			return

		if last_drawn_point.distance_to(snapped_point) > 5.0:
			trace_line.add_point(snapped_point)
			play_crack_sound()
	else:
		trace_line.add_point(snapped_point)
		play_crack_sound()
		
	check_win_condition()

func play_crack_sound():
	if not crack_sound:
		return
		
	if time_since_last_crack < 0.1:
		return
		
	time_since_last_crack = 0.0
		
	if not crack_sounds.is_empty():
		crack_sound.stream = crack_sounds.pick_random()
		crack_sound.pitch_scale = randf_range(0.85, 1.15)
		crack_sound.volume_db = 8.0 
		crack_sound.play()

func get_closest_on_stencil(global_pos: Vector2) -> Vector2:
	var local_pos = master_line.to_local(global_pos)
	var points = master_line.points
	var closest_local = points[0]
	var min_dist = INF

	for i in range(points.size() - 1):
		var p1 = points[i]
		var p2 = points[i + 1]
		var segment_closest = Geometry2D.get_closest_point_to_segment(local_pos, p1, p2)
		var dist = local_pos.distance_to(segment_closest)

		if dist < min_dist:
			min_dist = dist
			closest_local = segment_closest

	return master_line.to_global(closest_local)

func trigger_loss():
	if not game_over:
		is_tracing = false
		game_over = true
		timer_active = false
		if skip_button:
			skip_button.hide() 
		if start_hint:
			start_hint.hide()
		if needle:
			needle.hide()
		trace_line.default_color = Color(1, 0, 0)
		
		# --- PLAY FAIL SOUND NODE ---
		if fail_sound:
			if fail_audio and fail_sound.stream == null:
				fail_sound.stream = fail_audio
			death_sound.play()
			fail_sound.play()
		
		if name_input:
			name_input.hide()
		if submit_button:
			submit_button.hide()
		if status_label:
			status_label.hide()
		
		if final_time_label:
			final_time_label.text = "CRACK! Cookie Broke.\nTime: " + String.num(run_timer, 2) + "s"
			
		if game_over_panel:
			game_over_panel.modulate.a = 0.0 
			game_over_panel.show()
			var tween = create_tween()
			tween.tween_property(game_over_panel, "modulate:a", 1.0, 0.5) 

func check_win_condition():
	if game_over or is_transitioning: 
		return

	var point_count = trace_line.get_point_count()
	if point_count < 15: 
		return 

	var first_point = trace_line.get_point_position(0)
	var last_point = trace_line.get_point_position(point_count - 1)
	var distance_to_start = first_point.distance_to(last_point)

	if point_count >= 5 and distance_to_start <= 5 and reached_wand_tip:
		cookies_completed_in_run += 1
		is_transitioning = true 
		if skip_button:
			skip_button.hide()
		if start_hint:
			start_hint.hide()
		if needle:
			needle.hide()
		trace_line.default_color = Color(0, 1, 0) 
		
		var transition_timer = get_tree().create_timer(1.5)
		
		if cookies_completed_in_run >= target_cookies_per_run:
			# --- PLAY GAME WIN SOUND NODE ---
			if game_win_sound:
				if run_complete_audio and game_win_sound.stream == null:
					game_win_sound.stream = run_complete_audio
				game_win_sound.volume_db = 5.0
				game_win_sound.play()
				
			game_over = true
			timer_active = false
			
			if name_input:
				name_input.text = ""
				name_input.editable = true
				name_input.show()
			if submit_button:
				submit_button.disabled = false
				submit_button.show()
			if status_label:
				status_label.text = ""
				status_label.show()
			
			if final_time_label:
				final_time_label.text = "🎉 CONGRATULATIONS! 🎉\nAll 3 Cookies Survived!\nFinal Time: " + String.num(run_timer, 2) + "s"
				
			if game_over_panel:
				game_over_panel.modulate.a = 0.0
				game_over_panel.show()
				var tween = create_tween()
				tween.tween_property(game_over_panel, "modulate:a", 1.0, 0.5)
				
		else:
			# --- PLAY INDIVIDUAL SUCCESS SOUND NODE ---
			if success_sound:
				if cookie_success_audio and success_sound.stream == null:
					success_sound.stream = cookie_success_audio
				success_sound.volume_db = 2.0
				success_sound.play()
				
			await transition_timer.timeout
			is_transitioning = false
			spawn_next_shape_in_run()

# --- BUTTON CONNECTION FUNCTIONS ---

func _on_skip_button_pressed():
	if skip_button:
		skip_button.hide()
	just_skipped_fractal = true
	spawn_next_shape_in_run()

func _on_play_again_button_pressed():
	if game_over_panel:
		var tween = create_tween()
		tween.tween_property(game_over_panel, "modulate:a", 0.0, 0.3)
		await tween.finished 
		game_over_panel.hide()
		
	start_new_run()

func _on_main_menu_button_pressed():
	SceneTransition.change_scene("res://dalgona/scenes/main_menu.tscn")

func reset_game():
	start_new_run()

func _on_submit_pressed():
	if not name_input or name_input.text.strip_edges() == "":
		if status_label:
			status_label.text = "Please enter a name!"
		return
	
	if submit_button:
		submit_button.disabled = true
	if name_input:
		name_input.editable = false
		
	if status_label:
		status_label.text = "Submitting..."
	
	# Generate a unique player ID using current Unix timestamp
	var player_id = str(Time.get_unix_time_from_system())
	
	# Convert current_difficulty integer to a readable string
	var diff_str = "Easy"
	if current_difficulty == 1:
		diff_str = "Medium"
	elif current_difficulty == 2:
		diff_str = "Hard"
	
	# Send score to the Next.js API using game identifier "DALGONA"
	NextjsClient.submit_score("DALGONA", player_id, name_input.text, float(run_timer), diff_str)

func _on_score_submitted(success: bool, message: String):
	if not status_label:
		return
		
	if success:
		status_label.text = "Score Saved!"
	else:
		status_label.text = "Error: " + message
		if submit_button:
			submit_button.disabled = false
		if name_input:
			name_input.editable = true
