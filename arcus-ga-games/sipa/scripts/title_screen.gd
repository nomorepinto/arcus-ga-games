extends Control

const GAME_SCENE_PATH = "res://sipa/scenes/main_game.tscn"

# Point these to your UI elements in the editor scene tree
@onready var play_button = $PopupPanel/MainVBox/PlayButton

func _ready():
	# Connect the play button signal so it triggers when clicked
	if play_button and not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed():
	# Instantly switch over to your main Sipa game scene
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
