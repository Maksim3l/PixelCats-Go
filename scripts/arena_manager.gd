extends Node2D

class_name ArenaManager

enum ArenaLevel {BATHROOM, BEDROOM, LIVINGROOM, KITCHEN, GARDEN, BOSS}

@export var arena_config: Resource
@export var player_character: Node2D
@export var enemy_spawn_point: Node2D
@export var enemies_per_arena: Dictionary = {
	ArenaLevel.BATHROOM: 3,
	ArenaLevel.BEDROOM: 3,
	ArenaLevel.LIVINGROOM: 3,
	ArenaLevel.KITCHEN: 3,
	ArenaLevel.GARDEN: 3,
	ArenaLevel.BOSS: 1
}
@export var enemy_types: Array[EnemyStats] = []

var bath_enemies: Array[int] = [0]  #bathroom the drencher
var bed_enemies: Array[int] = [1]  #mirror
var living_enemies: Array[int] = [2] #Roomba
var kitchen_enemies: Array[int] = [3] #Can opener
var garden_enemies: Array[int] = [4] #Hose
var end_enemies: Array[int] = [5,6] #God

# Current state
var current_difficulty: int = ArenaLevel.BATHROOM
var enemies_defeated: int = 0
var battle_active: bool = false
var current_enemies: Array = []
var arena_backgrounds: Dictionary = {}

@onready var timer = $Timer
@onready var parallax_bg = $ParallaxBackground

signal battle_started(difficulty)
signal battle_ended(difficulty)
signal difficulty_increased(new_difficulty)

func _ready():
	randomize()
	setup_arena_backgrounds()
	
func setup_arena_backgrounds():
	arena_backgrounds = {
		ArenaLevel.BATHROOM: preload("res://enviroment/house/1_bathroom/bathroom_base_double.png"),
		ArenaLevel.BEDROOM: preload("res://enviroment/house/3_living_room/room_window_double.png"),
		ArenaLevel.LIVINGROOM: preload("res://enviroment/house/3_living_room/room_base_double.png"),
		ArenaLevel.KITCHEN: preload("res://enviroment/house/1_bathroom/bathroom_towel_double.png"),
		ArenaLevel.GARDEN: preload("res://enviroment/house/3_living_room/room_plant_double.png"),
		ArenaLevel.BOSS: preload("res://enviroment/house/1_bathroom/bathroom_water_double.png"),
	}

func start_battle():
	battle_active = true
	enemies_defeated = 0
	emit_signal("battle_started", current_difficulty)
	change_arena_background(current_difficulty)
	spawn_enemies_for_current_difficulty()

func spawn_enemies_for_current_difficulty():
	for enemy in current_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	current_enemies.clear()
	
	var num_enemies = enemies_per_arena[current_difficulty]
	
	for i in range(num_enemies):
		var enemy = spawn_enemy_by_difficulty(current_difficulty)
		if enemy:
			current_enemies.append(enemy)
			await get_tree().create_timer(0.5).timeout

func spawn_enemy_by_difficulty(difficulty: int) -> Node2D:
	var enemy_instance = preload("res://screens/enemy.tscn").instantiate()
	
	var pool_to_use: Array[int]
	match difficulty:
		ArenaLevel.BATHROOM: 
			pool_to_use = bath_enemies
		ArenaLevel.BEDROOM: 
			pool_to_use = bed_enemies
		ArenaLevel.LIVINGROOM: 
			pool_to_use = living_enemies
		ArenaLevel.KITCHEN: 
			pool_to_use = kitchen_enemies
		ArenaLevel.GARDEN: 
			pool_to_use = garden_enemies
		ArenaLevel.BOSS: 
			pool_to_use =end_enemies
		_: 
			pool_to_use = living_enemies
	
	if pool_to_use.size() == 0:
		pool_to_use = living_enemies
	
	var random_index = pool_to_use[randi() % pool_to_use.size()]
	enemy_instance.enemy_data = enemy_types[random_index]
	enemy_instance.target = player_character
	player_character.current_target = enemy_instance
	enemy_instance.battle = self
	
	get_tree().current_scene.add_child(enemy_instance)
	return enemy_instance

func enemy_defeated(exp, gold):
	if player_character.has_method("add_experience"):
		player_character.add_experience(exp)
	
	if player_character.has_method("add_gold"):
		player_character.add_gold(gold)
	
	enemies_defeated += 1
	
	if enemies_defeated >= enemies_per_arena[current_difficulty]:
		arena_complete()
	else:
		var active_enemies = 0
		for enemy in current_enemies:
			if is_instance_valid(enemy) and not enemy.is_defeated:
				active_enemies += 1
		
		if active_enemies == 0:
			spawn_next_wave()

func spawn_next_wave():
	var enemies_remaining = enemies_per_arena[current_difficulty] - enemies_defeated
	var wave_size = min(3, enemies_remaining) 
	
	for i in range(wave_size):
		var enemy = spawn_enemy_by_difficulty(current_difficulty)
		if enemy:
			current_enemies.append(enemy)
			await get_tree().create_timer(0.5).timeout

func arena_complete():
	battle_active = false
	emit_signal("battle_ended", current_difficulty)
	
	if current_difficulty < ArenaLevel.BOSS:
		current_difficulty += 1
		emit_signal("difficulty_increased", current_difficulty)
		
		show_difficulty_transition()
		
		timer.wait_time = 5.0
		timer.start()
	else:
		game_completed()

func show_difficulty_transition():
	print("Difficulty increased to: " + str(current_difficulty))

func game_completed():
	current_difficulty = ArenaLevel.BATHROOM
	timer.wait_time = 10.0
	timer.start()

func change_arena_background(difficulty: int):
	if arena_backgrounds.has(difficulty):
		for child in parallax_bg.get_children():
			child.queue_free()
			
		var new_bg = arena_backgrounds[difficulty].instantiate()
		parallax_bg.add_child(new_bg)

func _on_timer_timeout():
	if not battle_active:
		start_battle()
