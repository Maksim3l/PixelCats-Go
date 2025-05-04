extends ParallaxBackground

class_name ArenaBackgroundController

@export var arena_manager_path: NodePath
@export var is_paused: bool = false

var save_file_path = "res://data/"
var save_file_name = "CatManager.tres"
var cat_manager = CatManager.new()

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
		if not FileAccess.file_exists(save_file_path + save_file_name):
			print("No save file found")
			return false
	
		var data = ResourceLoader.load(save_file_path + save_file_name)
		if not data:
			print("Error loading save file")
			return false
		change_background_for_arena(data.arena_level)

func change_background_for_arena(arena_level: int):
	var animation_name = "livingroom" 
	if arena_animations.has(arena_level):
		animation_name = arena_animations[arena_level]
		print(animation_name)
	
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
	var total_frames = bg.sprite_frames.get_frame_count(animation_name)
	
	if current_frame != 0 and randf() < 0.5:
		bg.frame = 0
		return
	
	var available_frames = []
	for i in range(total_frames):
		if i != current_frame:
			available_frames.append(i)
	
	if available_frames.size() > 0:
		bg.frame = available_frames[randi() % available_frames.size()]
	else:
		bg.frame = 0
	
func _on_switchbox_body_entered(body):
	if not is_paused and body == cat:
		change_frame_randomly(bg.animation)



func _on_battle_ended(difficulty):
	is_paused = false

func _on_battle_arena_difficulty_increased(new_difficulty):
	change_background_for_arena(new_difficulty)

func _on_battle_started(difficulty):
	is_paused = true
