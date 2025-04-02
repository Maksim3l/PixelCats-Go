# Player.gd
extends CharacterBody2D

var save_file_path = "res://data/"
var save_file_name = "PlayerSave.tres"
var playerData = PlayerData.new()

var max_health: int = playerData.max_health
var current_health: int = playerData.current_health
var attack: int = playerData.attack
var defense: int = playerData.defense
var gold: int = playerData.gold
var experience: int = playerData.experience
var level: int = playerData.level

@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer

var can_attack: bool = true
var current_target = null

func _ready():
	health_bar.value = current_health
	health_bar.max_value = max_health
	
	load_game()
	
func _input(event):
	if event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()

func _process(delta):
	if current_target and can_attack:
		attack_target()

func attack_target():
	can_attack = false
	var damage = attack
	if current_target and current_target.has_method("take_damage"):
		current_target.take_damage(damage)
	attack_timer.start()

func take_damage(amount):
	var actual_damage = max(1, amount - defense)
	current_health -= actual_damage
	health_bar.value = current_health
	
	if current_health <= 0:
		die()

func die():
	get_tree().change_scene_to_file("res://screens/title_screen.tscn")

func add_experience(amount):
	experience += amount
	check_level_up()

func add_gold(amount):
	gold += amount

func check_level_up():
	var exp_needed = level * 100  # Simple formula, adjust as needed
	if experience >= exp_needed:
		level_up()

func level_up():
	level += 1
	max_health += 10
	current_health = max_health
	attack += 2
	defense += 1

func _on_attack_timer_timeout():
	can_attack = true
	
func save_game():
	# Create PlayerData from current player state
	var data = PlayerData.from_player(self)
	
	# Create directory if it doesn't exist (this works only in editor)
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")
	
	# Save the resource to disk
	var error = ResourceSaver.save(data, save_file_path + save_file_name)
	if error != OK:
		print("Error saving game: ", error)
		return false
	
	print("Game saved successfully to: ", save_file_path + save_file_name)
	return true

func load_game():
	if not FileAccess.file_exists(save_file_path + save_file_name):
		print("No save file found")
		return false
	
	# Load the resource
	var data = ResourceLoader.load(save_file_path + save_file_name)
	if not data:
		print("Error loading save file")
		return false
	
	# Apply the data to the player
	data.apply_to_player(self)
	
	current_health = 100
	health_bar.value = current_health
	
	print("Game loaded successfully")
	return true
