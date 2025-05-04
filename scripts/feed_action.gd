extends CanvasLayer

@onready var mbtn = $UIBottom/Merge
@onready var fbtn = $UIBottom/Feed
@onready var ebtn = $UIBottom/Equipment
@onready var abtn = $UIBottom/Accessories
@onready var pbtn = $UIBottom/Pets

var active_cat
var global_data

var custom_font = preload("res://resources/pixel_sans.ttf")

func _ready():
	mbtn.add_theme_font_override("font", custom_font) 
	fbtn.add_theme_font_override("font", custom_font) 
	ebtn.add_theme_font_override("font", custom_font) 
	abtn.add_theme_font_override("font", custom_font) 
	pbtn.add_theme_font_override("font", custom_font) 
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
	pass # Replace with function body.


func _on_soft_pressed():
	pass # Replace with function body.


func _on_packet_pressed():
	pass # Replace with function body.


func _on_fish_pressed():
	active_cat.energy = active_cat.max_energy


func _on_back_pressed():
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
