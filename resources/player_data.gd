class_name PlayerData
extends Resource

enum ArenaLevel {BATHROOM, BEDROOM, LIVINGROOM, KITCHEN, GARDEN, BOSS}

# Player meta stats (these apply to the player, not individual cats)
@export var gold: int = 0
@export var energy: int = 3
@export var arena_level: int = ArenaLevel.BATHROOM
@export var position: Vector2 = Vector2.ZERO
@export var cats: Array = []  # Will store CatCharacter resources
@export var active_cat_id: String = ""  # ID of the currently active cat

func _init(p_gold = 0, p_energy = 3, p_arena_level = ArenaLevel.BATHROOM, 
		   p_position = Vector2.ZERO):
	gold = p_gold
	energy = p_energy
	arena_level = p_arena_level
	position = p_position
	cats = []  # Initialize with empty array

# Get the currently active cat
func get_active_cat() -> CatCharacter:
	for cat in cats:
		if cat.id == active_cat_id:
			return cat
	
	# If no active cat found but we have cats, set the first one as active
	if cats.size() > 0:
		active_cat_id = cats[0].id
		cats[0].is_active = true
		return cats[0]
	
	return null

# Create a new PlayerData from a player node
static func from_player(player: CharacterBody2D) -> PlayerData:
	var data = PlayerData.new()
	
	# Copy player meta info
	data.gold = player.gold
	data.energy = player.energy
	if "arena_level" in player:
		data.arena_level = player.arena_level
	else:
		data.arena_level = ArenaLevel.BATHROOM
	data.position = player.position
	
	# Copy cats
	if "cats" in player and player.cats != null:
		for cat_data in player.cats:
			data.cats.append(cat_data)
		
		# Set the active cat if defined in player
		if "active_cat_id" in player and player.active_cat_id != "":
			data.active_cat_id = player.active_cat_id
			# Make sure is_active flags are set correctly
			for cat in data.cats:
				cat.is_active = (cat.id == data.active_cat_id)
	else:
		# If player doesn't have cats yet, create a default one from player stats
		var cat = CatCharacter.new()
		cat.max_health = player.max_health
		cat.current_health = player.current_health
		cat.attack = player.attack
		cat.defense = player.defense
		cat.experience = player.experience
		cat.level = player.level
		cat.name = "Default Cat"
		cat.is_active = true
		data.cats.append(cat)
		data.active_cat_id = cat.id
	
	return data
	
# Apply saved data to a player node
func apply_to_player(player: CharacterBody2D) -> void:
	# Set basic player properties
	player.gold = gold
	player.energy = energy
	player.arena_level = arena_level
	player.position = position
	
	# Initialize the cats array if it doesn't exist yet
	if not "cats" in player or player.cats == null:
		player.cats = []
	else:
		# Clear existing cats to avoid duplicates
		player.cats.clear()
	
	# Add saved cats to the player
	for cat in cats:
		player.cats.append(cat)
	
	# Set the active cat ID
	player.active_cat_id = active_cat_id
	
	# Set the main player stats from the active cat
	var active_cat = get_active_cat()
	if active_cat:
		player.max_health = active_cat.max_health
		player.current_health = active_cat.current_health
		player.attack = active_cat.attack
		player.defense = active_cat.defense
		player.experience = active_cat.experience
		player.level = active_cat.level
	
	# Update health bar if it exists
	if player.has_node("HealthBar"):
		player.health_bar.value = player.current_health
		player.health_bar.max_value = player.max_health
