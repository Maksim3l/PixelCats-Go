class_name PlayerData
extends Resource

enum ArenaLevel {BATHROOM, BEDROOM, LIVINGROOM, KITCHEN, GARDEN, BOSS}
# Player stats
@export var max_health: int = 100
@export var current_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var gold: int = 0
@export var experience: int = 0
@export var level: int = 1
@export var arena_level: int = ArenaLevel.BATHROOM
@export var energy: int = 3

# Optional: Add a position property to save player's position
@export var position: Vector2 = Vector2.ZERO

func _init(p_max_health = 100, p_current_health = 100, p_attack = 10, 
		   p_defense = 5, p_gold = 0, p_experience = 0, 
		   p_level = 1, p_arena_level = ArenaLevel.BATHROOM,
		   p_energy = 3, p_position = Vector2.ZERO):
	max_health = p_max_health
	current_health = p_current_health
	attack = p_attack
	defense = p_defense
	gold = p_gold
	experience = p_experience
	level = p_level
	arena_level = p_arena_level
	position = p_position
	energy = p_energy

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
	if "arena_level" in player:
		data.arena_level = player.arena_level
	else:
		data.arena_level = ArenaLevel.BATHROOM
	data.position = player.position
	data.energy = player.energy
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
	player.arena_level = arena_level
	player.energy = energy
	player.position = position
	
	# Update health bar if it exists
	if player.has_node("HealthBar"):
		player.health_bar.value = player.current_health
		player.health_bar.max_value = max_health
