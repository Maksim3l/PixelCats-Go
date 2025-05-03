# ItemManager.gd
extends Node

var weapons_resource = preload("res://resources/Weapons.gd").new()
var armor_resource = preload("res://resources/armor.gd").new()

# Cat-specific inventories (Dictionary where key is cat index, value is inventory array)
var cat_inventories = {}

var save_file_path = "res://data/"
var save_file_name = "CatManager.tres"
var inventory_file_name = "CatInventories.tres"
var cat_manager

# Initialize the item manager
func _ready():
	load_cat_manager()
	load_all_inventories()
	
func load_cat_manager():
	if not FileAccess.file_exists(save_file_path + save_file_name):
		print("No cat manager save file found")
		cat_manager = CatManager.new()
		return false

	var data = ResourceLoader.load(save_file_path + save_file_name)
	if not data or not data is CatManager:
		print("Error loading cat manager or invalid format")
		cat_manager = CatManager.new()
		return false
	
	cat_manager = data
	return true
	
# Get the active cat's inventory
func get_active_inventory() -> Array:
	if not cat_manager:
		load_cat_manager()
	
	var active_cat_index = cat_manager.active_cat_index
	return get_cat_inventory(active_cat_index)

# Get inventory for a specific cat by index
func get_cat_inventory(cat_index: int) -> Array:
	if not cat_inventories.has(cat_index):
		cat_inventories[cat_index] = []
	
	return cat_inventories[cat_index]

# Get an item by its ID
func get_item(item_id: String) -> Item:
	var item = weapons_resource.get_weapon(item_id)
	if item:
		return item
		
	item = armor_resource.get_armor(item_id)
	if item:
		return item
		
	print("Item not found: ", item_id)
	return null

# Add item to active cat's inventory
func add_to_inventory(item_id: String) -> bool:
	var item = get_item(item_id)
	if not item:
		return false
	
	var inventory = get_active_inventory()
	inventory.append(item)
	save_all_inventories()
	return true

# Add item to specific cat's inventory
func add_to_cat_inventory(cat_index: int, item_id: String) -> bool:
	var item = get_item(item_id)
	if not item:
		return false
	
	var inventory = get_cat_inventory(cat_index)
	inventory.append(item)
	save_all_inventories()
	return true

# Remove item from active cat's inventory
func remove_from_inventory(item_id: String) -> bool:
	var inventory = get_active_inventory()
	for i in range(inventory.size()):
		if inventory[i].id == item_id:
			inventory.remove_at(i)
			save_all_inventories()
			return true
	
	return false

# Remove item from specific cat's inventory
func remove_from_cat_inventory(cat_index: int, item_id: String) -> bool:
	var inventory = get_cat_inventory(cat_index)
	for i in range(inventory.size()):
		if inventory[i].id == item_id:
			inventory.remove_at(i)
			save_all_inventories()
			return true
	
	return false

# Get active cat's inventory items by type
func get_inventory_by_type(item_type: int) -> Array:
	var result = []
	var inventory = get_active_inventory()
	
	for item in inventory:
		if item.item_type == item_type:
			result.append(item)
	
	return result

# Get active cat's inventory items by slot
func get_inventory_by_slot(slot: int) -> Array:
	var result = []
	var inventory = get_active_inventory()
	
	for item in inventory:
		if item.item_slot == slot:
			result.append(item)
	
	return result

# Save all cat inventories to .tres file
func save_all_inventories():
	if not cat_manager:
		return false
	
	# Create directory if it doesn't exist
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")
	
	# Create a Resource to save inventories
	var save_data = Resource.new()
	save_data.set_meta("cat_inventories", cat_inventories)
	
	# Save to .tres file
	var error = ResourceSaver.save(save_data, save_file_path + inventory_file_name)
	if error != OK:
		print("Error saving cat inventories: ", error)
		return false
	
	print("Cat inventories saved successfully")
	return true

# Load all cat inventories from .tres file
func load_all_inventories() -> bool:
	if not FileAccess.file_exists(save_file_path + inventory_file_name):
		print("No inventory file found")
		return false
	
	# Load the resource
	var loaded_data = ResourceLoader.load(save_file_path + inventory_file_name)
	if not loaded_data:
		print("Error loading inventory file")
		return false
	
	# Get the saved cat inventories
	if loaded_data.has_meta("cat_inventories"):
		cat_inventories = loaded_data.get_meta("cat_inventories")
		print("Cat inventories loaded successfully")
		return true
	
	print("No cat_inventories metadata found")
	return false

# Equip item on active cat
func equip_item_on_active_cat(player: CharacterBody2D, item_id: String) -> bool:
	var item = get_item(item_id)
	if not item:
		return false
	
	if not player.has_method("equip_item"):
		print("Player doesn't have equip_item method")
		return false
	
	var slot = item.get_slot_name() 
	
	var item_data = {
		"id": item.id,
		"name": item.name,
		"texture": item.texture_path,
		"attack_bonus": item.attack_bonus,
		"defense_bonus": item.defense_bonus,
		"health_bonus": item.health_bonus,
		"energy_bonus": item.energy_bonus,
	}
	
	return player.equip_item(item_data, slot)

# Unequip item from active cat
func unequip_item_from_active_cat(player: CharacterBody2D, slot: String) -> bool:
	if not player.has_method("unequip_item"):
		print("Player doesn't have unequip_item method")
		return false
	
	return player.unequip_item(slot)

# Transfer item between cats
func transfer_item(from_cat_index: int, to_cat_index: int, item_id: String) -> bool:
	var from_inventory = get_cat_inventory(from_cat_index)
	
	for i in range(from_inventory.size()):
		if from_inventory[i].id == item_id:
			var item = from_inventory[i]
			from_inventory.remove_at(i)
			
			var to_inventory = get_cat_inventory(to_cat_index)
			to_inventory.append(item)
			
			save_all_inventories()
			return true
	
	return false

# Get all inventories
func get_all_inventories() -> Dictionary:
	return cat_inventories

# Clear inventory for a specific cat
func clear_cat_inventory(cat_index: int):
	if cat_inventories.has(cat_index):
		cat_inventories[cat_index].clear()
		save_all_inventories()

# Add starting equipment for a new cat
func add_starting_equipment(cat_index: int):
	# Give each new cat some basic equipment
	add_to_cat_inventory(cat_index, "basic_sword")
	add_to_cat_inventory(cat_index, "leather_chest")
	save_all_inventories()
