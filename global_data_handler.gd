extends Node

var global_data: GlobalData

const SAVE_PATH = "res://data/GlobalDataSave.tres"

func _ready():
	load_game()

func save_game():
	if global_data:
		global_data.save_global_data(SAVE_PATH)

func load_game():
	global_data = GlobalData.load_global_data(SAVE_PATH)
	
	if not global_data:
		global_data = GlobalData.new()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

func set_coming_from(scene_name: String):
	global_data.coming_from_last = scene_name
	save_game()

func get_coming_from() -> String:
	return global_data.coming_from_last

func add_gold(amount: int):
	global_data.gold += amount
	save_game()
	
func add_pet(pet_name: String):
	if pet_name not in global_data.bought_pets:
		global_data.bought_pets.append(pet_name)
		save_game()
		
func has_pet(pet_name: String) -> bool:
	return pet_name in global_data.bought_pets
