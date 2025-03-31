extends Area2D

@onready var bg = $"../BG"
@onready var cat = $"../../../../CenterLeft/player"
@export var is_paused: bool = false

func change_frame_randomly():
	bg.stop()
	var current_frame = bg.frame
	var total_frames = bg.sprite_frames.get_frame_count('living_room')
	
	var random_frame
	if total_frames > 1:
		random_frame = randi() % total_frames
		while random_frame == current_frame:
			random_frame = randi() % total_frames
	else:
		random_frame = 0
	
	bg.frame = random_frame
func _ready():
	change_frame_randomly()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused 

func _on_body_entered(body):
	if not is_paused and body == cat:
		change_frame_randomly()
