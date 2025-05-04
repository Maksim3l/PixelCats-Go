extends Node

var cat_manager: CatManager
const SAVE_PATH = "res://data/CatManager.tres"

func _ready():
	load_cat_manager()

func load_cat_manager():
	var loaded = CatManager.load_cats(SAVE_PATH)
	if loaded == null:
		print("No saved data found. Initializing new CatManager.")
		cat_manager = CatManager.new()
	else:
		cat_manager = loaded
		print("Cat Manager loaded with ", cat_manager.cats.size(), " cats")
		print("Active cat index: ", cat_manager.active_cat_index)

func save_cat_manager():
	if cat_manager:
		cat_manager.save_cats(SAVE_PATH)

func add_new_cat() -> int:
	var new_index = cat_manager.add_new_cat()
	save_cat_manager()
	return new_index

func get_active_cat() -> CatData:
	return cat_manager.get_active_cat()

func switch_cat(index: int) -> CatData:
	var switched_cat = cat_manager.switch_cat(index)
	save_cat_manager()
	return switched_cat

func remove_cat(index: int) -> bool:
	var result = cat_manager.remove_cat(index)
	save_cat_manager()
	return result

func get_all_cats() -> Array[CatData]:
	return cat_manager.cats

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_cat_manager()
		get_tree().quit()
