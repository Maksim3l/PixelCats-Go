class_name GlobalData
extends Resource

@export var coming_from_last = "none"
@export var gold: int = 0
@export var treat: int = 3
@export var unlocked_pets = {}
@export var unlocked_accessories = {}

# Uncomment and use this for unlocked cats
# @export var unlocked_cats = []

@export var collected_armor_ids: Array[String] = []


func _init(p_coming_from_last = "none", p_gold = 0):
	coming_from_last = p_coming_from_last
	gold = p_gold
	unlocked_pets = {}
	unlocked_accessories = {}

func set_property(key: String, value):
	unlocked_pets[key] = value
	
	
func get_property(key: String, default_value = null):
	if key in unlocked_pets:
		return unlocked_pets[key]
	return default_value
	
func add_accessory(accessory_name: String):
	if accessory_name not in unlocked_accessories:
		unlocked_accessories[accessory_name] = true

func has_accessory(accessory_name: String) -> bool:
	return accessory_name in unlocked_accessories and unlocked_accessories[accessory_name]
	
func save_global_data(path: String) -> bool:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data"):
		var make_dir_result = dir.make_dir("data")
		if make_dir_result != OK:
			print("Failed to create data directory: ", make_dir_result)
			return false
	
	# Save the resource
	var error = ResourceSaver.save(self, path)
	if error != OK:
		print("Error saving global data: ", error)
		return false
	
	print("Global data saved successfully to ", path)
	return true
	
static func load_global_data(path: String) -> GlobalData:
	if not FileAccess.file_exists(path):
		print("No global data save file found")
		return GlobalData.new()
		
	var data = ResourceLoader.load(path)
	if not data or not data is GlobalData:
		print("Error loading global data or invalid format")
		return GlobalData.new()
	
	return data

func add_collected_armor(armor_id: String) -> void:
	if not collected_armor_ids.has(armor_id):
		collected_armor_ids.append(armor_id)

func has_collected_armor(armor_id: String) -> bool:
	return collected_armor_ids.has(armor_id)

func get_collected_armor_items() -> Array[Item]:
	var result: Array = []
	for id in collected_armor_ids:
		var item = Armor.get_armor(id)
		if item != null:
			result.append(item)
	return result

func remove_collected_armor(armor_id: String) -> void:
	if collected_armor_ids.has(armor_id):
		collected_armor_ids.erase(armor_id)

func sell_collected_armor(armor_id: String) -> bool:
	if not collected_armor_ids.has(armor_id):
		print("Armor not in inventory: ", armor_id)
		return false

	var armor_item = Armor.get_armor(armor_id)
	if armor_item == null:
		print("Invalid armor ID: ", armor_id)
		return false
	
	collected_armor_ids.erase(armor_id)
	gold += armor_item.gold_value
	print("Sold ", armor_id, " for ", armor_item.gold_value, " gold.")
	return true
