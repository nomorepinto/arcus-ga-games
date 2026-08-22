extends Node

# Custom signals that the two games' UI scripts will listen for
signal score_submitted(success: bool, message: String)
signal leaderboard_received(success: bool, data: Array)

# Confidential keys that should eventually be loaded from res://shared/config/ .env file.
const API_URL = Config.API_URL
const API_KEY = Config.API_KEY

# --- SCORE SUBMISSION ---
func submit_score(game_id: String, player_id: String, player_name: String, score: float) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Bind request node to callback for later deletion
	http_request.request_completed.connect(_on_submit_completed.bind(http_request))
	
	var url = API_URL + "/score"
	var headers = [
		"Content-Type: application/json",
		"x-api-key: " + API_KEY
	]
	
	var payload = {
		"PK": "GAME#" + game_id.to_upper(),
		"SK": "PLAYER#" + player_id,
		"PlayerName": player_name,
		"Score": score
	}
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		score_submitted.emit(false, "Failed to initiate score submission.")
		http_request.queue_free()
	
func _on_submit_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest) -> void:
	http_request.queue_free() # Clean up the node
	
	if response_code == 200:
		score_submitted.emit(true, "Score saved successfully.")
	else:
		score_submitted.emit(false, "API Error: " + str(response_code))
	
# --- LEADERBOARD FETCHING ---
func get_leaderboard(game_id: String, limit: int = 10) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_leaderboard_completed.bind(http_request))
	
	# Pass game_id so DynamoDB knows which game score to pull
	var url = API_URL + "/leaderboard?game=" + game_id.to_upper() + "&limit=" + str(limit)
	var headers = [
		"Content-Type: application/json",
		"x-api-key: " + API_KEY
	]
	
	http_request.request(url, headers, HTTPClient.METHOD_GET)

func _on_leaderboard_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest) -> void:
	http_request.queue_free()
	
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		# Assuming our API returns a JSON array of the top scores
		leaderboard_received.emit(true, json.data)
	else:
		leaderboard_received.emit(false, [])
