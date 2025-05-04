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
	ArenaLevel.BOSS: 2
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
var enemies_spawned: int = 0
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
	
	var active_cat = CatHandler.get_active_cat()
	if active_cat:
		current_difficulty = active_cat.arena_level
		
	if player_character.has_method("walk"):
		player_character.walk()

func save_game():
	var active_cat = CatHandler.get_active_cat()
	active_cat.arena_level = current_difficulty
	active_cat.temp_attack = 0
	active_cat.temp_defense = 0
	
	var all_cats = CatHandler.get_all_cats()
	all_cats[CatHandler.cat_manager.active_cat_index] = active_cat
	
	CatHandler.save_cat_manager()

func start_battle():
	if enemies_spawned >= enemies_per_arena[current_difficulty]:
		return null
	else: 
		battle_active = true
		emit_signal("battle_started", current_difficulty)
		spawn_enemies_for_current_difficulty()

func spawn_enemies_for_current_difficulty():
	if player_character.current_target != null and is_instance_valid(player_character.current_target) and not player_character.current_target.is_defeated:
		return null
	spawn_enemy_by_difficulty(current_difficulty)
	enemies_spawned += 1

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
			pool_to_use = end_enemies
		_: 
			pool_to_use = living_enemies
	
	if pool_to_use.size() == 0:
		pool_to_use = living_enemies
	
	var rnd
	if difficulty == ArenaLevel.BOSS:
		if enemies_defeated == 0:
			rnd = pool_to_use[0]
		else:
			rnd = pool_to_use[1]
	else: 
		rnd = pool_to_use[randi() % pool_to_use.size()]
	
	enemy_instance.enemy_data = enemy_types[rnd]
	enemy_instance.target = player_character
	player_character.current_target = enemy_instance
	enemy_instance.battle = self
	
	enemy_spawn_point.add_child(enemy_instance)
	return enemy_instance

func enemy_defeated(exp, gold):
	if player_character.has_method("add_experience"):
		player_character.add_experience(exp)
	
	if player_character.has_method("add_gold"):
		player_character.add_gold(gold)
	
	enemies_defeated += 1
	
	player_character.current_target = null
	battle_active = false
	emit_signal("battle_ended", current_difficulty)
	if player_character.has_method("walk"):
		player_character.walk()
	
	if enemies_defeated >= enemies_per_arena[current_difficulty]:
		arena_complete()

func arena_complete():
	battle_active = false
	emit_signal("battle_ended", current_difficulty)
	
	if current_difficulty < ArenaLevel.BOSS:
		current_difficulty += 1
		emit_signal("difficulty_increased", current_difficulty)
				
		show_difficulty_transition()
		
		save_game()
		
		timer.wait_time = 5.0
		timer.start()
	else:
		game_completed()
	enemies_spawned = 0
	enemies_defeated = 0

func show_difficulty_transition():
	print("Difficulty increased to: " + str(current_difficulty))

func game_completed():
	current_difficulty = ArenaLevel.BATHROOM
	
	save_game()
	timer.wait_time = 10.0
	timer.start()

func _on_timer_timeout():
	if not battle_active && enemies_defeated < enemies_per_arena[current_difficulty]:
		start_battle()
