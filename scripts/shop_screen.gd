extends Node2D

#@onready var audio2 = $Organizer/UIBottom/BottomUI/click
@onready var audio = $Organizer/UITopLeft/AudioStreamPlayer2D2
@onready var treat = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"

var active_cat

func _ready():
	
	MusicManager.play_main_music()
	var global_data = GlobalDataHandler.global_data
	var active_cat = CatHandler.get_active_cat()

	gold.text = str(global_data.gold)
	treat.text = str(global_data.treat)
	energy.text = str(active_cat.max_energy) + "/" + str(active_cat.energy)


func _on_back_pressed():
	# Pridobi trenutno aktivno mačko
	active_cat = CatHandler.get_active_cat()
	
	if active_cat == null:
		print("No active cat found, returning to idle screen")
		_load_scene("res://screens/idle_screen.tscn")
		return
	
	# Shrani trenutne podatke o mački
	var all_cats = CatHandler.get_all_cats()
	all_cats[CatHandler.cat_manager.active_cat_index] = active_cat
	CatHandler.save_cat_manager()

	
	audio.play()
	await get_tree().create_timer(0.25).timeout
	_load_scene("res://screens/idle_screen.tscn")

func _load_scene(scene_path):
	var new_scene = load(scene_path).instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
