extends CanvasLayer

@onready var audio1 = $UICenter/AudioStreamPlayer2D
@onready var audio = $UIBottom/BottomUI/AudioStreamPlayer2D
@onready var mbtn = $UIBottom/BottomUI/Bisquit
@onready var fbtn = $UIBottom/BottomUI/Catnip
@onready var ebtn = $UIBottom/BottomUI/Soft
@onready var abtn = $UIBottom/BottomUI/Packet
@onready var pbtn = $UIBottom/BottomUI/Fish

var active_cat
var global_data

func _ready():
	active_cat = CatHandler.get_active_cat()
	global_data = GlobalDataHandler.global_data
	
	update_button_states()

func update_button_states():
	# Disable buttons if no treats left
	var has_treats = global_data.treat > 0
	mbtn.disabled = not has_treats
	fbtn.disabled = not has_treats
	ebtn.disabled = not has_treats
	abtn.disabled = not has_treats
	pbtn.disabled = not has_treats

func _on_bisquit_pressed():
	if global_data.treat > 0:
		audio.play()
		
		# Heal the cat
		var heal_amount = min(30, active_cat.max_health - active_cat.current_health)
		active_cat.current_health += heal_amount
		
		# Deduct a treat
		GlobalDataHandler.use_treat(1)
		
		print("Healed for", heal_amount, "HP. Remaining treats:", global_data.treat)
		
		update_button_states()

func _on_catnip_pressed():
	if global_data.treat > 0:
		audio.play()
		active_cat.temp_attack += 10
		GlobalDataHandler.use_treat(1)
		
		update_button_states()

func _on_soft_pressed():
	if global_data.treat > 0:
		audio.play()
		active_cat.temp_defense += 12
		GlobalDataHandler.use_treat(1)
		
		update_button_states()

func _on_packet_pressed():
	if global_data.treat > 0:
		audio.play()
		active_cat.max_health += 5
		active_cat.current_health += 5
		GlobalDataHandler.use_treat(1)
		
		update_button_states()

func _on_fish_pressed():
	if global_data.treat > 0:
		audio.play()
		active_cat.energy = active_cat.max_energy
		GlobalDataHandler.use_treat(1)
		
		update_button_states()

func _on_back_pressed():
	audio1.play()
	await get_tree().create_timer(0.25).timeout
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
