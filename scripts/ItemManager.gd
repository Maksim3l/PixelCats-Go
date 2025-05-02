# ItemManager.gd
extends Node

var weapons_resource = preload("res://resources/Weapons.gd").new()
var armor_resource = preload("res://resources/armor.gd").new()

# Player inventory
var player_inventory = []

# Initialize the item manager
func _ready():
	# If needed, load saved inventory
	pass

# Get an item by its ID
func get_item(item_id: String) -> Item:
	# Try to find item in weapons
	var item = weapons_resource.get_weapon(item_id)
	if item:
		return item
		
	# Try to find item in armor
	item = armor_resource.get_armor(item_id)
	if item:
		return item
		
	print("Item not found: ", item_id)
	return null

# Add item to player inventory
func add_to_inventory(item_id: String) -> bool:
	var item = get_item(item_id)
	if not item:
		return false
		
	player_inventory.append(item)
	return true

# Remove item from player inventory
func remove_from_inventory(item_id: String) -> bool:
	for i in range(player_inventory.size()):
		if player_inventory[i].id == item_id:
			player_inventory.remove_at(i)
			return true
			
	return false

# Get all items in inventory
func get_inventory() -> Array:
	return player_inventory

# Get inventory items by type
func get_inventory_by_type(item_type: int) -> Array:
	var result = []
	
	for item in player_inventory:
		if item.item_type == item_type:
			result.append(item)
			
	return result

# Get inventory items by slot
func get_inventory_by_slot(slot: int) -> Array:
	var result = []
	
	for item in player_inventory:
		if item.item_slot == slot:
			result.append(item)
			
	return result

# Save inventory
func save_inventory():
	var save_data = []
	
	for item in player_inventory:
		save_data.append(item.to_dict())
		
	var file = FileAccess.open("res://data/PlayerInventory", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		return true
	
	return false

# Load inventory 
func load_inventory() -> bool:
	if not FileAccess.file_exists("res://data/PlayerInventory"):
		return false
		
	var file = FileAccess.open("res://data/PlayerInventory", FileAccess.READ)
	if not file:
		return false
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return false
		
	var save_data = json.get_data()
	if not save_data is Array:
		return false
		
	# Clear current inventory
	player_inventory.clear()
	
	# Load items
	for item_data in save_data:
		if item_data is Dictionary:
			var item = Item.from_dict(item_data)
			player_inventory.append(item)
			
	return true


# Helper function to equip an item on the player
func equip_item_on_player(player: CharacterBody2D, item_id: String) -> bool:
	var item = get_item(item_id)
	if not item:
		return false
	
	# Check if the player has an equip_item method
	if not player.has_method("equip_item"):
		print("Player doesn't have equip_item method")
		return false
	
	# Get slot and layer from item
	var slot = item.get_slot_name() 
	
	# Create item data dictionary
	var item_data = {
		"id": item.id,
		"name": item.name,
		"texture": item.texture_path,
		"attack_bonus": item.attack_bonus,
		"defense_bonus": item.defense_bonus,
		"health_bonus": item.health_bonus,
		"energy_bonus": item.energy_bonus,
	}
	
	# Call the equip method on player
	return player.equip_item(item_data, slot)

# Helper function to unequip an item from player
func unequip_item_from_player(player: CharacterBody2D, slot: String, layer: String = "base") -> bool:
	# Check if the player has an unequip_item method
	if not player.has_method("unequip_item"):
		print("Player doesn't have unequip_item method")
		return false
	
	# Call the unequip method on player
	return player.unequip_item(slot, layer)
