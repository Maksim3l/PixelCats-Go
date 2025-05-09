class_name GlobalData
extends Resource

@export var coming_from_last = "none"
@export var gold: int = 0
@export var treat: int = 3
@export var unlocked_pets = {}
# Uncomment and use this for unlocked cats
# @export var unlocked_cats = []

func _init(p_coming_from_last = "none", p_gold = 0):
	coming_from_last = p_coming_from_last
	gold = p_gold
	unlocked_pets = {}

func set_property(key: String, value):
	unlocked_pets[key] = value
	
func get_property(key: String, default_value = null):
	if key in unlocked_pets:
		return unlocked_pets[key]
	return default_value
	
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
