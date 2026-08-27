extends AudioStreamPlayer

@onready var background_layer = $BackgroundLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
		
	if not playing:
		play()

# Optional: Call this if you want to hide the background during active gameplay
func set_background_visible(is_visible: bool):
	if background_layer:
		background_layer.visible = is_visible
