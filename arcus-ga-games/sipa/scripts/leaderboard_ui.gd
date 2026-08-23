extends Control

const GAME_SCENE_PATH = "res://sipa/scenes/main_game.tscn"

@onready var title_label = $PopupPanel/MainVBox/TitleLabel
@onready var loading_label = $PopupPanel/MainVBox/LoadingLabel
@onready var score_list = $PopupPanel/MainVBox/ScrollBox/ScoreList
@onready var play_button = $PopupPanel/MainVBox/PlayButton

func _ready():
	# Force the VBoxContainer to fill the ScrollContainer's width
	score_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Connect the play button
	play_button.pressed.connect(_on_play_pressed)
	
	# Listen for the data from our Next.js backend
	NextjsClient.leaderboard_received.connect(_on_leaderboard_received)
	
	# Automatically load our leaderboard
	load_leaderboard("SIPA")

# Call this from MainGame.gd when you want to pop up the leaderboard
func load_leaderboard(game_id: String):
	title_label.text = game_id.to_upper() + " LEADERBOARD"
	loading_label.show()
	
	# Clear any old scores from the previous time it was opened
	for child in score_list.get_children():
		child.queue_free()
	
	# Ask Next.js to fetch the top 10 scores for this specific game
	NextjsClient.get_leaderboard(game_id, 10)

func _on_leaderboard_received(success: bool, response_data: Dictionary):
	loading_label.hide()
	
	# Extract the array from Dictionary
	var scores_array = []
	if response_data.has("Items"):
		scores_array = response_data["Items"]
	elif response_data.has("data"):
		scores_array = response_data["data"]
		
	if success and scores_array.size() > 0:
		var rank = 1
		for player in scores_array:
			var row_label = Label.new()
			
			# Format: "1. Juan - 45"
			# (DynamoDB handles Dalgona's floats and Sipa's integers automatically)
			row_label.text = str(rank) + ". " + player["PlayerName"] + " - " + str(player["Score"])
			
			# Add some basic styling and add it to the VBoxContainer
			row_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			score_list.add_child(row_label)
			rank += 1
	else:
		var error_label = Label.new()
		error_label.text = "No scores found or connection error."
		error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		score_list.add_child(error_label)

func _on_play_pressed():
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
