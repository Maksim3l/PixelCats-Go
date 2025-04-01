class_name PlayerData
extends Resource

# Player stats
@export var max_health: int = 100
@export var current_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var gold: int = 0
@export var experience: int = 0
@export var level: int = 1

# Optional: Add a position property to save player's position
@export var position: Vector2 = Vector2.ZERO

func _init(p_max_health = 100, p_current_health = 100, p_attack = 10, 
		   p_defense = 5, p_gold = 0, p_experience = 0, 
		   p_level = 1, p_position = Vector2.ZERO):
	max_health = p_max_health
	current_health = p_current_health
	attack = p_attack
	defense = p_defense
	gold = p_gold
	experience = p_experience
	level = p_level
	position = p_position

# Create a new player data object from a player node
static func from_player(player: CharacterBody2D) -> PlayerData:
	var data = PlayerData.new()
	data.max_health = player.max_health
	data.current_health = player.current_health
	data.attack = player.attack
	data.defense = player.defense
	data.gold = player.gold
	data.experience = player.experience
	data.level = player.level
	data.position = player.position
	return data
	
# Apply saved data to a player node
func apply_to_player(player: CharacterBody2D) -> void:
	player.max_health = max_health
	player.current_health = 100  
	player.attack = attack
	player.defense = defense
	player.gold = gold
	player.experience = experience
	player.level = level
	player.position = position
	
	# Update health bar if it exists
	if player.has_node("HealthBar"):
		player.health_bar.value = player.current_health
		player.health_bar.max_value = max_health
