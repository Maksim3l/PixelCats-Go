class_name CatCharacter
extends Resource

# Cat identification
@export var id: String = ""
@export var name: String = "Default Cat"
@export var cat_type: String = "Basic"  # e.g., "Warrior", "Healer", "Speedy"
@export var is_active: bool = false     # Is this the currently selected cat?

# Cat stats
@export var max_health: int = 100
@export var current_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: int = 100
@export var experience: int = 0
@export var level: int = 1

# Optional appearance properties
@export var color: Color = Color(1, 1, 1, 1)
@export var sprite_frame: int = 0

func _init():
	if id == "":
		id = str(randi())  # Generate random ID if none provided

# Utility methods
func is_alive() -> bool:
	return current_health > 0

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	
func take_damage(amount: int) -> int:
	var actual_damage = max(1, amount - defense)
	current_health = max(0, current_health - actual_damage)
	return actual_damage
	
func add_experience(amount: int) -> bool:
	experience += amount
	return check_level_up()
	
func check_level_up() -> bool:
	var exp_needed = level * 100  # Simple formula, adjust as needed
	if experience >= exp_needed:
		level_up()
		return true
	return false
	
func level_up() -> void:
	level += 1
	max_health += 10
	current_health = max_health
	attack += 2
	defense += 1
	speed += 5

# Apply stat boosts (e.g., from items or abilities)
func apply_boost(stat_name: String, value: float) -> void:
	match stat_name:
		"max_health":
			max_health = int(max_health * value)
			current_health = max_health  # Restore health on boost
		"attack":
			attack = int(attack * value)
		"defense":
			defense = int(defense * value)
		"speed":
			speed = int(speed * value)
