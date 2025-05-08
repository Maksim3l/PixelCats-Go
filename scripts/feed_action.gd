extends CanvasLayer

@onready var mbtn = $UIBottom/Bisquit
@onready var fbtn = $UIBottom/Catnip
@onready var ebtn = $UIBottom/Soft
@onready var abtn = $UIBottom/Packet
@onready var pbtn = $UIBottom/Fish

var active_cat
var global_data

var custom_font = preload("res://resources/pixel_sans.ttf")

func _ready():
	active_cat = CatHandler.get_active_cat()
	global_data = GlobalDataHandler.global_data
	


# Here to be copy and paisted for convenience
# get_tree().change_scene_to_file("res://screens/battle.tscn")

func _on_bisquit_pressed():
	if (active_cat.current_health < active_cat.max_health):
		if ((active_cat.max_health-active_cat.current_health) < 30):
			active_cat.current_health == active_cat.max_health
		else:
			active_cat.current_health += 30

func _on_catnip_pressed():
	active_cat.temp_attack += 10

func _on_soft_pressed():
	active_cat.temp_defense += 12


func _on_packet_pressed():
	active_cat.max_health += 5
	active_cat.current_health += 5

func _on_fish_pressed():
	active_cat.energy = active_cat.max_energy


func _on_back_pressed():
	var all_cats = CatHandler.get_all_cats()
	all_cats[CatHandler.cat_manager.active_cat_index] = active_cat
	
	CatHandler.save_cat_manager()
	
	if GlobalDataHandler.global_data.coming_from_last == "Battle Arena":
		var battle = load("res://screens/battle.tscn").instantiate()
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(battle)
		get_tree().current_scene = battle
	else:
		var idle_screen = load("res://screens/idle_screen.tscn").instantiate()
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(idle_screen)
		get_tree().current_scene = idle_screen
