extends Control

# Path to your title screen or main game scene
@export_file("*.tscn") var next_scene_path: String = "res://sipa/scenes/title_screen.tscn"

@onready var video_player = $VideoStreamPlayer

func _ready():
	# Connect the finished signal so it moves on when the video ends
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	_transition_to_next_scene()

func _transition_to_next_scene():
	SceneTransition.change_scene(next_scene_path)
