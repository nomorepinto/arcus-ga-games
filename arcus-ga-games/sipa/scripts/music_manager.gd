extends AudioStreamPlayer

@onready var background_layer = $BackgroundLayer

@export var start_offset: float = 1.12
@export var volume_boost_db: float = 3.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	volume_db = volume_boost_db
	
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
		
	if not playing:
		play(start_offset)

# Optional: Call this if you want to hide the background during active gameplay
func set_background_visible(is_visible: bool):
	if background_layer:
		background_layer.visible = is_visible
