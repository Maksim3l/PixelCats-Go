extends CharacterBody2D
const TORNADO = preload("res://screens/tornado.tscn")
@onready var merge: Node2D = $".."
signal collision_detected

var speed = 100.0
var gravity = 980.0
var direction = Vector2(1, 0)  
var is_stopped = false 

func _ready():
	boost_stats()

func boost_stats():
	# Increase all stats by 20%
	var cat = CatHandler.get_active_cat()
	print("Attack: ", cat.attack)
	print("Defense: ", cat.defense)
	cat.attack = int(cat.attack * 1.2)
	cat.defense = int(cat.defense * 1.2)

	var all_cats = CatHandler.get_all_cats()
	all_cats[CatHandler.cat_manager.active_cat_index] = cat
	
	print("Stats boosted by 20%:")
	print("Attack: ", cat.attack)
	print("Defense: ", cat.defense)
	
	save_boosted_stats()

func save_boosted_stats():
	CatHandler.save_cat_manager()

func _physics_process(delta):
	# Check if movement should be stopped
	if is_stopped:
		velocity = Vector2.ZERO
	else:
		# Set constant horizontal velocity for automatic movement
		velocity.x = direction.x * speed
	
	# Apply movement
	move_and_slide()
	
	# Check for collisions only if we're not already stopped
	if not is_stopped:
		for i in get_slide_collision_count():
			is_stopped = true  # Stop this cat
			emit_signal("collision_detected")  # Signal the parent
			spawn_tornado()
			break  # Only need to emit once

func spawn_tornado():
	print("collision")
	
# Function to stop movement
func stop_movement():
	is_stopped = true
	velocity = Vector2.ZERO
