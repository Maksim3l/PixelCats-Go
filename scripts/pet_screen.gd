extends Node2D
@onready var treat = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"

var active_cat

func _ready():
	
	var global_data = GlobalDataHandler.global_data

	gold.text = str(global_data.gold)

	
	return true

func _on_back_pressed():
	# Shranimo trenutnega ljubljenčka, če je aktiven
	if active_cat:
		var all_cats = CatHandler.get_all_cats()
		all_cats[CatHandler.cat_manager.active_cat_index] = active_cat
		CatHandler.save_cat_manager()
	
	# Preverimo, od kod smo prišli, da se pravilno vrnemo
	var previous_scene = GlobalDataHandler.global_data.coming_from_last
	
	match previous_scene:
		"Battle Arena":
			_load_scene("res://screens/battle.tscn")
		_, "Idle Screen":
			_load_scene("res://screens/idle_screen.tscn")
		_:
			print("Unknown previous scene:", previous_scene)

func _load_scene(scene_path):
	var new_scene = load(scene_path).instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
