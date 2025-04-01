extends Node2D

@export var enemy_spawn_point: Node2D
@export var player_character: Node2D
@export var enemies_per_battle: int = 3
@export var enemy_types: Array[EnemyStats] = []

var enemies_defeated: int = 0
var battle_active: bool = false
var current_enemies: Array = []

@export var area_difficulty: int = 1  # 1=Easy, 2=Medium, 3=Hard
var easy_enemies: Array[int] = [0, 1, 2]  
var medium_enemies: Array[int] = [3, 4, 5, 6] 
var hard_enemies: Array[int] = [7, 8, 9]

func _ready():
	randomize()

func start_battle():
	battle_active = true
	enemies_defeated = 0
	spawn_enemies()

func spawn_enemies():
	
	for enemy in current_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	current_enemies.clear()
	
	for i in range(enemies_per_battle):
		var enemy_instance = preload("res://screens/enemy.tscn").instantiate()
		
		var random_index = randi() % enemy_types.size()
		enemy_instance.enemy_data = enemy_types[random_index]
		
		var offset = Vector2(i * 100, 0)  
		enemy_instance.position = enemy_spawn_point.position + offset
		
		enemy_instance.target = player_character
		
		add_child(enemy_instance)

func select_enemy_by_difficulty() -> EnemyStats:
	var pool_to_use: Array[int]
	match area_difficulty:
		1: pool_to_use = easy_enemies
		2: pool_to_use = medium_enemies
		3: pool_to_use = hard_enemies
		_: pool_to_use = easy_enemies 
	var random_index = pool_to_use[randi() % pool_to_use.size()]
	return enemy_types[random_index]

func select_random_enemy() -> EnemyStats:
	var random_index = randi() % enemy_types.size()
	return enemy_types[random_index]
	
func spawn_mixed_difficulty_enemies():
	var enemy_counts = {
		"hard": 1,
		"medium": 1,
		"easy": 1
	}
	
	var position_offset = 0
	for i in range(enemy_counts.hard):
		spawn_specific_difficulty_enemy(3, position_offset)
		position_offset += 100
	
	for i in range(enemy_counts.medium):
		spawn_specific_difficulty_enemy(2, position_offset)
		position_offset += 100
	
	for i in range(enemy_counts.easy):
		spawn_specific_difficulty_enemy(1, position_offset)
		position_offset += 100
	
func spawn_specific_difficulty_enemy(difficulty: int, offset: float):
	var enemy_instance = preload("res://screens/enemy.tscn").instantiate()
	
	var pool_to_use: Array[int]
	match difficulty:
		1: pool_to_use = easy_enemies
		2: pool_to_use = medium_enemies
		3: pool_to_use = hard_enemies
		_: pool_to_use = easy_enemies
	   
	var random_index = pool_to_use[randi() % pool_to_use.size()]
	enemy_instance.enemy_data = enemy_types[random_index]
	enemy_instance.position = enemy_spawn_point.position + Vector2(offset, 0)
	enemy_instance.target = player_character
	add_child(enemy_instance)
	current_enemies.append(enemy_instance)

func enemy_defeated(exp, gold):
	# Give rewards to player
	if player_character.has_method("add_experience"):
		player_character.add_experience(exp)
	
	if player_character.has_method("add_gold"):
		player_character.add_gold(gold)
	
	enemies_defeated += 1
	if enemies_defeated >= enemies_per_battle:
		battle_complete()

func battle_complete():
	battle_active = false
