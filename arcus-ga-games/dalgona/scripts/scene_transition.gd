extends CanvasLayer

var rect: ColorRect
var bg_music: AudioStreamPlayer # <--- NEW

func _ready():
	layer = 128
	
	# 1. Setup the fade rectangle
	rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	
	# 2. Setup the global music player
	bg_music = AudioStreamPlayer.new()
	bg_music.stream = load("res://dalgona/assets/Squid game 2 - Round and round [Clean Instrumental] - Kpop HQ STUDIO.mp3") # <--- PASTE PATH HERE
	add_child(bg_music)
	bg_music.play() # Starts playing immediately when the game launches

# We added 'fade_color' here, and set it to default to BLACK
func change_scene(target_scene_path: String, duration: float = 0.5, fade_color: Color = Color.BLACK):
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Set the rectangle to your chosen color, but keep it transparent to start
	rect.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0)
	
	# 1. Fade in the color
	var tween_in = create_tween()
	tween_in.tween_property(rect, "color:a", 1.0, duration)
	await tween_in.finished
	
	# 2. Swap scenes behind the color
	get_tree().change_scene_to_file(target_scene_path)
	
	await get_tree().tree_changed
	await get_tree().process_frame
	
	# 3. Fade out the color
	var tween_out = create_tween()
	tween_out.tween_property(rect, "color:a", 0.0, duration)
	await tween_out.finished
	
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
