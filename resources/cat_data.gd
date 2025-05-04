class_name CatData
extends Resource

enum ArenaLevel {BATHROOM, BEDROOM, LIVINGROOM, KITCHEN, GARDEN, BOSS}

# cat identity
@export var cat_name: String = "Whiskers"
@export var cat_sprite: String = "res://characters/main/main.png"

# cat stats
@export var max_health: int = 100
@export var current_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var experience: int = 0
@export var level: int = 1
@export var arena_level: int = ArenaLevel.BATHROOM
@export var max_energy: int = 3
@export var energy: int = 3

# Optional: Add a position property to save cat's position
@export var position: Vector2 = Vector2.ZERO

func _init(p_cat_name = "Whiskers", p_cat_sprite = "res://characters/main/main.png",
		   p_max_health = 100, p_current_health = 100, p_attack = 10, 
		   p_defense = 5, p_experience = 0, 
		   p_level = 1, p_arena_level = ArenaLevel.BATHROOM, p_max_energy = 3,
		   p_energy = 3, p_position = Vector2.ZERO):
	cat_name = p_cat_name
	cat_sprite = p_cat_sprite
	max_health = p_max_health
	current_health = p_current_health
	attack = p_attack
	defense = p_defense
	experience = p_experience
	level = p_level
	arena_level = p_arena_level
	position = p_position
	max_energy = p_max_energy
	energy = p_energy

# Create a new cat data object from a cat node
static func from_cat(cat: CharacterBody2D) -> CatData:
	var data = CatData.new()
	
	if "cat_name" in cat:
		data.cat_name = cat.cat_name
	if "cat_sprite" in cat:
		data.cat_sprite = cat.cat_sprite

	data.max_health = cat.max_health
	data.current_health = cat.current_health
	data.attack = cat.attack
	data.defense = cat.defense
	data.experience = cat.experience
	data.level = cat.level
	if "arena_level" in cat:
		data.arena_level = cat.arena_level
	else:
		data.arena_level = ArenaLevel.BATHROOM
	data.position = cat.position
	data.energy = cat.energy
	data.max_energy = cat.max_energy
	return data
	
# Apply saved data to a cat node
func apply_to_cat(cat: CharacterBody2D) -> void:
	if "cat_name" in cat:
		cat.cat_name = cat_name
	if "cat_sprite" in cat:
		cat.cat_sprite = cat_sprite
		
		
	cat.max_health = max_health
	cat.current_health = max_health
	cat.attack = attack
	cat.defense = defense
	cat.experience = experience
	cat.level = level
	cat.arena_level = arena_level
	cat.max_energy = max_energy
	cat.energy = energy
	cat.position = position
	
	# Update health bar if it exists
	if cat.has_node("HealthBar"):
		cat.health_bar.value = cat.current_health
		cat.health_bar.max_value = max_health
