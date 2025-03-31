class_name Enemy
extends CharacterBody2D

@export var stats: EnemyStats
var possible_stats: Array = []



#func set_random_stats(stats_list):
#	var random_index = randi() % stats_list.size()
#	stats = stats_list[random_index]

#	apply_stats()

#func apply_stats():
#	health = stats.health
#	damage = stats.damage
#	speed = stats.speed
