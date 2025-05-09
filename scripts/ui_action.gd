extends CanvasLayer
@onready var audio = $UIBottom/TextureRect/AudioStreamPlayer2D2
@onready var mbtn = $UIBottom/Merge
@onready var fbtn = $UIBottom/Feed
@onready var ebtn = $UIBottom/Equipment
@onready var abtn = $UIBottom/Accessories
@onready var pbtn = $UIBottom/Pets

var active_cat
var global_data

var custom_font = preload("res://resources/pixel_sans.ttf")

func _ready():

	active_cat = CatHandler.get_active_cat()
	global_data = GlobalDataHandler.global_data

# Here to be copy and paisted for convenience
# get_tree().change_scene_to_file("res://screens/battle.tscn")

func _on_merge_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	var new_scene = load("res://screens/choose_cat.tscn").instantiate()
	
	global_data.coming_from_last = get_tree().current_scene.name
	GlobalDataHandler.global_data = global_data
	GlobalDataHandler.save_game()
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene


func _on_feed_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	var new_scene = load("res://screens/feeding_screen.tscn").instantiate()
	
	global_data.coming_from_last = get_tree().current_scene.name
	GlobalDataHandler.global_data = global_data
	GlobalDataHandler.save_game()
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene


func _on_equipment_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	pass # Replace with function body.


func _on_accessories_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	var new_scene = load("res://screens/accessory_screen.tscn").instantiate()
	
	global_data.coming_from_last = get_tree().current_scene.name
	GlobalDataHandler.global_data = global_data
	GlobalDataHandler.save_game()
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene


func _on_pets_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	var new_scene = load("res://screens/pet_screen.tscn").instantiate()
	
	global_data.coming_from_last = get_tree().current_scene.name
	GlobalDataHandler.global_data = global_data
	GlobalDataHandler.save_game()
	
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene


func _on_battle_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	if (active_cat.energy != 0):
		get_tree().change_scene_to_file("res://screens/battle.tscn")
	else:
		print("Not enought energy.")
