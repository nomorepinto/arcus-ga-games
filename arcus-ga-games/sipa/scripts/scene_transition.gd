extends CanvasLayer

@onready var color_rect = $ColorRect # Assumes a full-screen black ColorRect is a child

func _ready():
	if color_rect:
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		color_rect.modulate.a = 0.0

func change_scene(target_scene: String):
	if not color_rect:
		get_tree().change_scene_to_file(target_scene)
		return
		
	# Block mouse inputs during transition
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Fade Out (To Black)
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.4)
	await tween.finished
	
	# Change the actual scene
	get_tree().change_scene_to_file(target_scene)
	
	# Fade In (From Black)
	var fadeInTween = create_tween()
	fadeInTween.tween_property(color_rect, "modulate:a", 0.0, 0.4)
	await fadeInTween.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
