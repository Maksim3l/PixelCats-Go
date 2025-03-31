extends Node2D

var enemy_scene = preload("res://screens/enemy.tscn")

var time_accumulator = 0.0
var interval = 2.5
var in_battle: bool = false

#func _ready():
#	load_enemy_stats("res://resources/enemy/stats")

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= interval:
		time_accumulator = 0.0
		Input.action_press("pause")
		in_battle = true

#func load_enemy_stats(folder_path):
#	var dir = Directory.new()
#	if dir.open(folder_path) == OK:
#		dir.list_dir_begin()
#		var filename = dir.get_next()
#		while filename != "":
#			if filename.ends_with(".tres"):
#				var resource_path = folder_path + filename
#				var resource = load(resource_path)
#				if resource is EnemyStats:
#					possible_stats.append(resource)
#			filename = dir.get_next()
#		dir.list_dir_end()


#func _on_timer_timeout():
#	var enemy_instance = enemy_scene.instance()
#	enemy_instance.random
#	enemy_instance.set_random_stats(possible_stats)
#	add_child(enemy_instance)
