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
@export var temp_attack: int = 0
@export var defense: int = 5
@export var temp_defense: int = 0
@export var experience: int = 0
@export var level: int = 1
@export var arena_level: int = ArenaLevel.BATHROOM
@export var max_energy: int = 3
@export var energy: int = 3

# Optional: Add a position property to save cat's position
@export var position: Vector2 = Vector2.ZERO
@export var equipped_head_sf_path: String = "" 
@export var equipped_body_sf_path: String = "" 

@export var equipped_armor: Dictionary = {
	Item.ItemSlot.HEAD: null,
	Item.ItemSlot.TORSO: null,
	Item.ItemSlot.ARM_BACK: null,
	Item.ItemSlot.LEG_FRONT: null,
}
@export var equipped_weapon: Item = null

func _init(p_cat_name = "Whiskers", p_cat_sprite = "res://characters/main/main.png",
		   p_max_health = 100, p_current_health = 100, p_attack = 10, 
		   p_defense = 5, p_experience = 0, 
		   p_level = 1, p_arena_level = ArenaLevel.BATHROOM, p_max_energy = 3,
		   p_energy = 3, p_position = Vector2.ZERO, p_temp_attack = 0, p_temp_defense = 0, p_equipped_head_sf_path = "", p_equipped_body_sf_path = ""):
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
	temp_attack = p_temp_attack
	temp_defense = p_temp_defense
	equipped_head_sf_path = p_equipped_head_sf_path
	equipped_body_sf_path = p_equipped_body_sf_path

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
	data.temp_attack = cat.temp_attack
	data.temp_defense = cat.temp_defense
	if cat.has_node("HeadSlot") and cat.get_node("HeadSlot") is AnimatedSprite2D:
		var slot = cat.get_node("HeadSlot") as AnimatedSprite2D
		if slot.sprite_frames and slot.sprite_frames.resource_path:
			data.equipped_head_sf_path = slot.sprite_frames.resource_path
	if cat.has_node("BodySlot") and cat.get_node("BodySlot") is AnimatedSprite2D:
		var slot = cat.get_node("BodySlot") as AnimatedSprite2D
		if slot.sprite_frames and slot.sprite_frames.resource_path:
			data.equipped_body_sf_path = slot.sprite_frames.resource_path
			
	if "equipped_weapon" in cat:
		data.equipped_weapon = cat.equipped_weapon
	
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
	cat.temp_attack = temp_attack
	cat.temp_defense = temp_defense
	
	if cat.has_node("HeadSlot") and cat.get_node("HeadSlot") is AnimatedSprite2D:
		var slot = cat.get_node("HeadSlot") as AnimatedSprite2D
		if equipped_head_sf_path != "" and equipped_head_sf_path != null:
			var sf = load(equipped_head_sf_path)
			if sf is SpriteFrames:
				slot.sprite_frames = sf
				slot.visible = true
			else:
				slot.sprite_frames = null; slot.visible = false
		else:
			slot.sprite_frames = null; slot.visible = false
	
	# TELO
	if cat.has_node("BodySlot") and cat.get_node("BodySlot") is AnimatedSprite2D:
		var slot = cat.get_node("BodySlot") as AnimatedSprite2D
		if equipped_body_sf_path != "" and equipped_body_sf_path != null:
			var sf = load(equipped_body_sf_path)
			if sf is SpriteFrames:
				slot.sprite_frames = sf
				slot.visible = true
			else:
				slot.sprite_frames = null; slot.visible = false
		else:
			slot.sprite_frames = null; slot.visible = false
	
	# Update health bar if it exists
	if cat.has_node("HealthBar"):
		cat.health_bar.value = cat.current_health
		cat.health_bar.max_value = max_health
		
	if "equipped_weapon" in cat:
		cat.equipped_weapon = equipped_weapon

func equip_weapon(weapon: Item) -> Item:
	if not weapon:
		return null
		
	var previous_weapon = equipped_weapon
	
	# Remove stats from previously equipped weapon if any
	if previous_weapon:
		remove_weapon_stats(previous_weapon)
	
	# Equip new weapon and apply its stats
	equipped_weapon = weapon
	apply_weapon_stats(weapon)
	
	return previous_weapon

# Apply weapon stats to cat
func apply_weapon_stats(weapon: Item) -> void:
	if not weapon:
		return
		
	max_health += weapon.health_bonus
	current_health = min(current_health + weapon.health_bonus, max_health)
	attack += weapon.attack_bonus
	defense += weapon.defense_bonus
	max_energy += weapon.energy_bonus
	energy = min(energy + weapon.energy_bonus, max_energy)

# Remove weapon stats from cat
func remove_weapon_stats(weapon: Item) -> void:
	if not weapon:
		return
		
	max_health -= weapon.health_bonus
	current_health = min(current_health, max_health)
	attack -= weapon.attack_bonus
	defense -= weapon.defense_bonus
	max_energy -= weapon.energy_bonus
	energy = min(energy, max_energy)

# Unequip current weapon
func unequip_weapon() -> Item:
	if equipped_weapon != null:
		var weapon = equipped_weapon
		remove_weapon_stats(weapon)
		equipped_weapon = null
		return weapon
	return null

# Get equipped weapon
func get_equipped_weapon() -> Item:
	return equipped_weapon

# Check if a weapon is equipped
func has_weapon_equipped() -> bool:
	return equipped_weapon != null

# Get weapon attack bonus
func get_weapon_attack() -> int:
	if equipped_weapon:
		return equipped_weapon.attack_bonus
	return 0

# Get weapon defense bonus  
func get_weapon_defense() -> int:
	if equipped_weapon:
		return equipped_weapon.defense_bonus
	return 0

# Get weapon health bonus
func get_weapon_health() -> int:
	if equipped_weapon:
		return equipped_weapon.health_bonus
	return 0

# Get weapon energy bonus
func get_weapon_energy() -> int:
	if equipped_weapon:
		return equipped_weapon.energy_bonus
	return 0

func equip_armor(armor: Item) -> Item:
	if not armor or armor.item_type != Item.ItemType.ARMOR:
		return null
		
	var previous_armor = null
	
	# Check if armor slot is valid
	if armor.item_slot in equipped_armor:
		# Remove stats from previously equipped armor if any
		previous_armor = equipped_armor[armor.item_slot]
		if previous_armor:
			remove_armor_stats(previous_armor)
		
		# Equip new armor and apply its stats
		equipped_armor[armor.item_slot] = armor
		apply_armor_stats(armor)
		
	return previous_armor

# Apply armor stats to cat
func apply_armor_stats(armor: Item) -> void:
	if not armor:
		return
		
	max_health += armor.health_bonus
	current_health = min(current_health + armor.health_bonus, max_health)
	attack += armor.attack_bonus
	defense += armor.defense_bonus
	max_energy += armor.energy_bonus
	energy = min(energy + armor.energy_bonus, max_energy)

# Remove armor stats from cat
func remove_armor_stats(armor: Item) -> void:
	if not armor:
		return
		
	max_health -= armor.health_bonus
	current_health = min(current_health, max_health)
	attack -= armor.attack_bonus
	defense -= armor.defense_bonus
	max_energy -= armor.energy_bonus
	energy = min(energy, max_energy)

# Unequip armor from a specific slot
func unequip_armor(slot: int) -> Item:
	if slot in equipped_armor and equipped_armor[slot] != null:
		var armor = equipped_armor[slot]
		remove_armor_stats(armor)
		equipped_armor[slot] = null
		return armor
	return null

# Get equipped armor in a specific slot
func get_equipped_armor(slot: int) -> Item:
	if slot in equipped_armor:
		return equipped_armor[slot]
	return null

# Check if a slot has armor equipped
func has_armor_equipped(slot: int) -> bool:
	return slot in equipped_armor and equipped_armor[slot] != null

# Get total defense from all equipped armor
func get_total_armor_defense() -> int:
	var total = 0
	for slot in equipped_armor:
		var armor = equipped_armor[slot]
		if armor:
			total += armor.defense_bonus
	return total

# Get total attack bonus from all equipped armor
func get_total_armor_attack() -> int:
	var total = 0
	for slot in equipped_armor:
		var armor = equipped_armor[slot]
		if armor:
			total += armor.attack_bonus
	return total

# Get total health bonus from all equipped armor
func get_total_armor_health() -> int:
	var total = 0
	for slot in equipped_armor:
		var armor = equipped_armor[slot]
		if armor:
			total += armor.health_bonus
	return total

# Get total energy bonus from all equipped armor
func get_total_armor_energy() -> int:
	var total = 0
	for slot in equipped_armor:
		var armor = equipped_armor[slot]
		if armor:
			total += armor.energy_bonus
	return total

func get_total_attack() -> int:
	return attack + get_total_armor_attack() + get_weapon_attack()

# Get total defense including weapon and armor  
func get_total_defense() -> int:
	return defense + get_total_armor_defense() + get_weapon_defense()

# Get total health including weapon and armor
func get_total_health() -> int:
	return max_health + get_total_armor_health() + get_weapon_health()

# Get total energy including weapon and armor
func get_total_energy() -> int:
	return max_energy + get_total_armor_energy() + get_weapon_energy()

func reset_temps():
	temp_attack = 0
	temp_defense = 0
