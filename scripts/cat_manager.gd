class_name CatManager
extends Resource

@export var cats: Array[PlayerData] = []
@export var active_cat_index: int = 0

func _init():
	if cats.size() == 0:
		add_new_cat()

func add_new_cat():
	var new_cat = PlayerData.new()
	cats.append(new_cat)
	return cats.size() - 1

func get_active_cat() -> PlayerData:
	if cats.size() == 0:
		add_new_cat()
	if active_cat_index >= cats.size():
		active_cat_index = 0
	return cats[active_cat_index]
	
func switch_cat(index: int) -> PlayerData:
	if index >= 0 and index < cats.size():
		active_cat_index = index
		return get_active_cat()
	return null

# Remove a cat
func remove_cat(index: int) -> bool:
	if index >= 0 and index < cats.size():
		cats.remove_at(index)
		
		# Adjust active cat index if needed
		if active_cat_index >= cats.size():
			active_cat_index = max(0, cats.size() - 1)
			
		return true
	return false

func save_cats(path: String) -> bool:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data"):
		var make_dir_result = dir.make_dir("data")
		if make_dir_result != OK:
			print("Failed to create data directory: ", make_dir_result)
			return false
	
	# Save the resource
	var error = ResourceSaver.save(self, path)
	if error != OK:
		print("Error saving cats: ", error)
		return false
	
	print("Cats saved successfully to ", path)
	return true
	
	
static func load_cats(path: String) -> CatManager:
	if not FileAccess.file_exists(path):
		print("No cat manager save file found")
		return CatManager.new()
		
	var data = ResourceLoader.load(path)
	if not data or not data is CatManager:
		print("Error loading cat manager or invalid format")
		return CatManager.new()
	
	return data
