extends ParallaxBackground

class_name ArenaBackgroundController

@export var arena_manager_path: NodePath
@export var is_paused: bool = false

var arena_animations = {
	0: "bathroom",     
	1: "bedroom",      
	2: "livingroom",   
	3: "kitchen",      
	4: "garden",      
	5: "boss"   
}

@onready var bg = $"ParallaxLayer/BG" 
@onready var cat = $"../../CenterLeft/player"
@onready var arena_manager = get_node_or_null(arena_manager_path)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	if arena_manager:
		arena_manager.connect("battle_started", Callable(self, "_on_battle_started"))
		arena_manager.connect("battle_ended", Callable(self, "_on_battle_ended"))
		arena_manager.connect("difficulty_increased", Callable(self, "_on_difficulty_increased"))
		
		change_background_for_arena(arena_manager.current_difficulty)
	else:
		change_frame_randomly("livingroom")

func change_background_for_arena(arena_level: int):
	var animation_name = "livingroom" 
	if arena_animations.has(arena_level):
		animation_name = arena_animations[arena_level]
	
	if bg.sprite_frames.has_animation(animation_name):
		bg.stop()
		bg.animation = animation_name
		change_frame_randomly(animation_name)
	else:
		var animations = bg.sprite_frames.get_animation_names()
		if animations.size() > 0:
			bg.animation = animations[0]
			change_frame_randomly(animations[0])

func change_frame_randomly(animation_name: String):
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
	
func _on_switchbox_body_entered(body):
	if not is_paused and body == cat:
		if bg.animation:
			change_frame_randomly(bg.animation)

func _on_battle_ended(difficulty):
	is_paused = false

func _on_battle_arena_difficulty_increased(new_difficulty):
	change_background_for_arena(new_difficulty)


func _on_battle_started(difficulty):
	is_paused = true
	change_background_for_arena(difficulty)
