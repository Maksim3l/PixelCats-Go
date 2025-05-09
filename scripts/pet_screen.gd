extends Node2D

@onready var audio2 = $Organizer/UIBottom/BottomUI/click
@onready var audio = $Organizer/UICenter/AudioStreamPlayer2D
@onready var treat = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"
@onready var animal_container = $Organizer/PetContainer
@onready var bunny_button = $Organizer/UIBottom/BottomUI/bunny
@onready var cow_button = $Organizer/UIBottom/BottomUI/cow
@onready var pig_button = $Organizer/UIBottom/BottomUI/pig
@onready var dog_button = $Organizer/UIBottom/BottomUI/dog
@onready var redpanda_button = $Organizer/UIBottom/BottomUI/redPanda

var prices = {
	"bunny": 100,
	"cow": 200,
	"pig": 300,
	"dog": 400,
	"redpanda": 500
}

var active_cat
var animal_keys = ["bunny", "cow", "pig", "dog", "redpanda"]

func _ready():
	
	MusicManager.play_main_music()
	var global_data = GlobalDataHandler.global_data
	gold.text = str(global_data.gold)

	# Posodobi stanje gumbov za vse živali
	update_button_states(global_data)

	# Naloži že kupljene živali
	for animal_key in animal_keys:
		var animal_count = global_data.get_property(animal_key + "_count", 0)
		for i in range(animal_count):
			_add_animal_to_screen(animal_key)

func update_button_states(global_data):
	bunny_button.disabled = global_data.gold < prices["bunny"]
	cow_button.disabled = global_data.gold < prices["cow"]
	pig_button.disabled = global_data.gold < prices["pig"]
	dog_button.disabled = global_data.gold < prices["dog"]
	redpanda_button.disabled = global_data.gold < prices["redpanda"]

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
	
	# Preveri, od kod je uporabnik prišel
	if GlobalDataHandler.global_data.coming_from_last == "Battle Arena":
		audio.play()
		await get_tree().create_timer(0.25).timeout
		_load_scene("res://screens/battle.tscn")
	else:
		audio.play()
		await get_tree().create_timer(0.25).timeout
		_load_scene("res://screens/idle_screen.tscn")

func _load_scene(scene_path):
	var new_scene = load(scene_path).instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func _on_BunnyButton_pressed():
	audio2.play()
	await get_tree().create_timer(0.25).timeout
	_buy_animal("bunny")

func _on_CowButton_pressed():
	audio2.play()
	await get_tree().create_timer(0.25).timeout
	_buy_animal("cow")

func _on_PigButton_pressed():
	audio2.play()
	await get_tree().create_timer(0.25).timeout
	_buy_animal("pig")

func _on_DogButton_pressed():
	audio2.play()
	await get_tree().create_timer(0.25).timeout
	_buy_animal("dog")

func _on_RedPandaButton_pressed():
	audio2.play()
	await get_tree().create_timer(0.25).timeout
	_buy_animal("redpanda")

func _buy_animal(animal_key):
	var global_data = GlobalDataHandler.global_data
	var price = prices[animal_key]
	
	if global_data.gold >= price:
		# Odstrani zlato
		global_data.gold -= price
		gold.text = str(global_data.gold)
		
		# Dodaj žival na ekran
		_add_animal_to_screen(animal_key)
		
		# Posodobi števec kupljenih živali
		var current_count = global_data.get_property(animal_key + "_count", 0)
		global_data.set_property(animal_key + "_count", current_count + 1)
		
		# Shrani spremembe
		GlobalDataHandler.save_game()
		
		# Posodobi stanje gumba
		update_button_states(global_data)
		
		print(animal_key.capitalize() + " kupljen!")
	else:
		print("Nimaš dovolj zlata za " + animal_key.capitalize() + "!")
		

func _add_animal_to_screen(animal_key):
	var animal_scene_path = "res://screens/animals/" + animal_key + ".tscn"
	var animal = load(animal_scene_path).instantiate()
	
	# Pridobi velikost vsebnika
	var container_rect = animal_container.get_rect()
	var container_size = container_rect.size
	
	# Nastavi naključno pozicijo za žival
	var random_x = randf_range(0, container_size.x - 64)
	var random_y = randf_range(0, container_size.y - 64)
	animal.position = Vector2(random_x, random_y)
	
	animal_container.add_child(animal)
