extends Node2D
const TORNADO = preload("res://screens/tornado.tscn")
@onready var cat1: CharacterBody2D = $CharacterBody2D
@onready var cat2: CharacterBody2D = $CharacterBody2D2
@onready var tornado: CharacterBody2D = $tornado
@onready var timer: Timer = $Timer
@onready var unlock = $unlock
@onready var tornado_animated_sprite: AnimatedSprite2D

var selected_cats = []
var cat1_data
var cat2_data

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.play_main_music()
	cat1_data = CatHandler.get_all_cats()[selected_cats[0]]
	cat2_data = CatHandler.get_all_cats()[selected_cats[1]]
	
	GlobalDataHandler.global_data.gold -= 50
	GlobalDataHandler.save_game()
	
	boost_stats()
	
	tornado.hide()
	if tornado.has_node("AnimatedSprite2D"):
		var found_sprite = tornado.get_node("AnimatedSprite2D")
		if found_sprite is AnimatedSprite2D:
			tornado_animated_sprite = found_sprite
		else:
			printerr("Node 'AnimatedSprite2D' inside tornado is not of type AnimatedSprite2D!")
	else:
		printerr("Tornado node does not have a child named 'AnimatedSprite2D'!")
	if not tornado_animated_sprite:
		printerr("Failed to get tornado_animated_sprite in _ready(). Animation might not play.")
	
	cat1.connect("collision_detected", Callable(self, "_on_cat_collision"))
	if not timer.timeout.is_connected(_on_tornado_timeout):
		timer.timeout.connect(_on_tornado_timeout)

func _process(delta: float) -> void:
	pass
	

func boost_stats():
	# Increase the stats of both cats by 20%
	cat1_data.attack = int(cat1_data.attack * 1.2)
	cat1_data.defense = int(cat1_data.defense * 1.2)
	
	cat2_data.attack = int(cat2_data.attack * 1.2)
	cat2_data.defense = int(cat2_data.defense * 1.2)
	# Save the updated cat data back into CatHandler
	CatHandler.get_all_cats()[selected_cats[0]] = cat1_data
	CatHandler.get_all_cats()[selected_cats[1]] = cat2_data

	print("Stats boosted by 20% for both cats:")
	print("Cat 1 - Attack: ", cat1_data.attack, ", Defense: ", cat1_data.defense)
	print("Cat 2 - Attack: ", cat2_data.attack, ", Defense: ", cat2_data.defense)
	
	# Save cat manager data
	CatHandler.save_cat_manager()
	 

func _on_cat_collision():
	# Hide the cat
	cat1.hide()
	cat2.queue_free()
	
	tornado.show()
	if tornado_animated_sprite: 
		tornado_animated_sprite.frame = 0 
		tornado_animated_sprite.play("default") 
	else:
		printerr("Cannot play tornado animation: tornado_animated_sprite is not set!")
	
	timer.wait_time = 0.6
	timer.one_shot = true
	timer.start()
	
func _on_tornado_timeout():
	print("Tornado will be hidden")
	unlock.play()
	tornado.hide()
	cat1.visible = true
	
	await get_tree().create_timer(1.2).timeout
	
	if GlobalDataHandler.global_data.coming_from_last == "Battle Arena":
		var battle = load("res://screens/battle.tscn").instantiate()
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(battle)
		get_tree().current_scene = battle
	else:
		var idle_screen = load("res://screens/idle_screen.tscn").instantiate()
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(idle_screen)
		get_tree().current_scene = idle_screen

	
