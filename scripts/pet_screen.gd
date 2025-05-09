extends Node2D

@onready var treat = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"
@onready var animal_container = $Organizer/PetContainer
@onready var bunny_button = $Organizer/UIBottom/BottomUI/bunny

var bunny_price = 100  # Cena za Bunny
var active_cat
var bunny_key = "bunny_count"

func _ready():
	var global_data = GlobalDataHandler.global_data
	gold.text = str(global_data.gold)

	# Preveri ali ima igralec dovolj zlata za Bunny
	update_button_states(global_data)

	# Naloži že kupljene Bunnyje
	var bunny_count = global_data.get_property(bunny_key, 0)
	for i in range(bunny_count):
		_add_bunny_to_screen()

func update_button_states(global_data):
	if global_data.gold >= bunny_price:
		bunny_button.disabled = false
	else:
		bunny_button.disabled = true

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

func _on_BunnyButton_pressed():
	var global_data = GlobalDataHandler.global_data
	
	if global_data.gold >= bunny_price:
		# Odstrani zlato
		global_data.gold -= bunny_price
		gold.text = str(global_data.gold)
		
		# Dodaj Bunny na ekran
		_add_bunny_to_screen()
		
		# Posodobi števec kupljenih Bunnyjev
		var current_bunny_count = global_data.get_property(bunny_key, 0)
		global_data.set_property(bunny_key, current_bunny_count + 1)
		
		# Shrani spremembe
		GlobalDataHandler.save_game()
		
		# Posodobi stanje gumba
		update_button_states(global_data)
		
		print("Bunny kupil!")
	else:
		print("Nimaš dovolj zlata!")

func _add_bunny_to_screen():
	var bunny = load("res://screens/animals/bunny.tscn").instantiate()
	
	# Pridobi velikost vsebnika
	var container_rect = animal_container.get_rect()
	var container_size = container_rect.size
	
	# Nastavi naključno pozicijo za bunnyja
	var random_x = randf_range(0, container_size.x - 64)  # 64 je širina bunny sprite
	var random_y = randf_range(0, container_size.y - 64)  # 64 je višina bunny sprite
	bunny.position = Vector2(random_x, random_y)
	
	animal_container.add_child(bunny)
