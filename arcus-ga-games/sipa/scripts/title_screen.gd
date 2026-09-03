extends Control

const GAME_SCENE_PATH = "res://sipa/scenes/main_game.tscn"

# Point these to your UI elements in the editor scene tree
@onready var popup_panel = $PopupPanel
@onready var play_button = $PopupPanel/MainVBox/PlayButton

func _ready():
	# Connect the play button signal so it triggers when clicked
	if play_button and not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)
	
	if popup_panel:
		popup_panel.modulate.a = 0.0
		popup_panel.scale = Vector2(0.9, 0.9)
		popup_panel.pivot_offset = popup_panel.size / 2.0
		
		var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(popup_panel, "modulate:a", 1.0, 0.5)
		tween.tween_property(popup_panel, "scale", Vector2.ONE, 0.5)

func _on_play_pressed():
	# Instantly switch over to your main Sipa game scene
	# Disable the button to prevent double-clicks
	play_button.disabled = true
	
	# Exit animation: shrink and fade out before switching scenes
	if popup_panel:
		var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_property(popup_panel, "modulate:a", 0.0, 0.3)
		tween.tween_property(popup_panel, "scale", Vector2(0.8, 0.8), 0.3)
		await tween.finished
	
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
