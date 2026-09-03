extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	# The 1.0 makes the fade take 1 full second, and Color.WHITE makes it a white flash!
	SceneTransition.change_scene("res://dalgona/scenes/main_menu.tscn", 0.4, Color.WHITE)
