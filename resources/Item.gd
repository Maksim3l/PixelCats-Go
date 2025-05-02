class_name Item
extends Resource

enum ItemType {WEAPON, ARMOR, ACCESSORY, CONSUMABLE}
enum ItemSlot {HEAD, TORSO, ARM_FRONT, ARM_BACK, LEG_FRONT, LEG_BACK, TAIL}
enum ItemLayer {BASE, TOP}

# Basic item properties
@export var id: String = ""
@export var name: String = ""
@export var texture_path: String = ""
@export var item_type: ItemType = ItemType.ACCESSORY
@export var item_slot: ItemSlot = ItemSlot.HEAD

# Item stats
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var health_bonus: int = 0
@export var energy_bonus: int = 0

# Cost and rarity
@export var gold_value: int = 10


func _init(p_id="", p_name="", p_texture_path="", 
		   p_item_type=ItemType.ACCESSORY, p_item_slot=ItemSlot.HEAD, 
		   p_attack_bonus=0, p_defense_bonus=0,
		   p_health_bonus=0, p_energy_bonus=0):
	id = p_id
	name = p_name
	texture_path = p_texture_path
	item_type = p_item_type
	item_slot = p_item_slot
	attack_bonus = p_attack_bonus
	defense_bonus = p_defense_bonus
	health_bonus = p_health_bonus
	energy_bonus = p_energy_bonus

# Convert slot enum to string for use with the player's equip system
func get_slot_name() -> String:
	match item_slot:
		ItemSlot.HEAD:
			return "head"
		ItemSlot.ARM_FRONT:
			return "arm_front"
		ItemSlot.ARM_BACK:
			return "arm_back"
		ItemSlot.LEG_FRONT:
			return "leg_front"
		ItemSlot.LEG_BACK:
			return "leg_back"
		ItemSlot.TORSO:
			return "torso"
		ItemSlot.TAIL:
			return "tail"
	return "head"  # Default


# Get dictionary representation of item for easier saving
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"texture": texture_path,
		"type": item_type,
		"slot": item_slot,
		"attack_bonus": attack_bonus,
		"defense_bonus": defense_bonus,
		"health_bonus": health_bonus,
		"energy_bonus": energy_bonus,
		"gold_value": gold_value,
	}
	
# Create an item from a dictionary
static func from_dict(data: Dictionary) -> Item:
	var item = Item.new()
	
	# Set basic properties
	if "id" in data: item.id = data.id
	if "name" in data: item.name = data.name
	if "texture" in data: item.texture_path = data.texture
	if "type" in data: item.item_type = data.type
	if "slot" in data: item.item_slot = data.slot
	
	# Set stats
	if "attack_bonus" in data: item.attack_bonus = data.attack_bonus
	if "defense_bonus" in data: item.defense_bonus = data.defense_bonus
	if "health_bonus" in data: item.health_bonus = data.health_bonus
	if "energy_bonus" in data: item.energy_bonus = data.energy_bonus
	
	# Set cost
	if "gold_value" in data: item.gold_value = data.gold_value
	
	return item
