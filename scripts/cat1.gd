extends CharacterBody2D
const TORNADO = preload("res://screens/tornado.tscn")
@onready var merge: Node2D = $".."
signal collision_detected
var speed = 100.0
var gravity = 980.0
var direction = Vector2(1, 0)  
var is_stopped = false 
# Player stats
var playerData = null
var max_health: int = 0
var current_health: int = 0
var attack: int = 0
var defense: int = 0
var gold: int = 0
var experience: int = 0
var level: int = 0

func _ready():
	# Load player data
	load_player_stats()
	
	# Apply 20% boost to all stats
	boost_stats()

func load_player_stats():
	var save_file_path = "res://data/"
	var save_file_name = "PlayerSave.tres"
	
	if not FileAccess.file_exists(save_file_path + save_file_name):
		print("No save file found, using default stats")
		# Set default values if no save file exists
		max_health = 100
		current_health = 100
		attack = 10
		defense = 5
		gold = 0
		experience = 0
		level = 1
		return
	
	# Load the resource
	playerData = ResourceLoader.load(save_file_path + save_file_name)
	if not playerData:
		print("Error loading save file, using default stats")
		# Set default values if loading fails
		max_health = 100
		current_health = 100
		attack = 10
		defense = 5
		gold = 0
		experience = 0
		level = 1
		return
	
	# Get the active cat from player data
	var active_cat = playerData.get_active_cat()
	if active_cat:
		# Copy the stats from the active cat
		max_health = active_cat.max_health
		current_health = active_cat.current_health
		attack = active_cat.attack
		defense = active_cat.defense
		experience = active_cat.experience
		level = active_cat.level
	else:
		print("No active cat found, using default stats")
		max_health = 100
		current_health = 100
		attack = 10
		defense = 5
		experience = 0
		level = 1
	
	# Load gold directly from player data
	gold = playerData.gold
	
	print("Player stats loaded successfully")

func boost_stats():
	# Increase all stats by 20%
	attack = int(attack * 1.2)
	defense = int(defense * 1.2)
	
	print("Stats boosted by 20%:")
	print("Attack: ", attack)
	print("Defense: ", defense)
	
	save_boosted_stats()

func save_boosted_stats():
	if playerData:
		# Get the active cat
		var active_cat = playerData.get_active_cat()
		if active_cat:
			# Update the active cat's stats
			active_cat.max_health = max_health
			active_cat.current_health = current_health
			active_cat.attack = attack
			active_cat.defense = defense
		else:
			print("No active cat found, cannot save boosted stats")
			return
		
		var save_file_path = "res://data/"
		var save_file_name = "PlayerSave.tres"
		
		# Create directory if it doesn't exist
		var dir = DirAccess.open("res://")
		if not dir.dir_exists("data"):
			dir.make_dir("data")
		
		# Save the resource to disk
		var error = ResourceSaver.save(playerData, save_file_path + save_file_name)
		if error != OK:
			print("Error saving boosted stats: ", error)
		else:
			print("Boosted stats saved successfully")

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
