extends Node2D

@export var player_character: Node2D
@onready var treat_label = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy_label = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold_label = $"Organizer/UITop/ProfileUI/Gold/value"

func _ready():
	randomize()
	
	var active_cat = CatHandler.get_active_cat()
	var global_data = GlobalDataHandler.global_data
	
	if not active_cat:
		print("No active cat found")
		return false
	
	# Poišči player_character pravilno
	player_character = get_node("Organizer/CenterBG/ParallaxBackground/ParallaxLayer3/player")
	
	if not player_character:
		print("Player character is not set!")
		return false
	
	# Posodobi UI vrednosti
	energy_label.text = str(active_cat.max_energy) + "/" + str(active_cat.energy)
	gold_label.text = str(global_data.gold)
	treat_label.text = str(global_data.treat)

	# Preveri, če ima player_character metodo za animacijo
	if player_character.has_method("play_animation"):
		player_character.play_animation("nap")
	elif player_character.has_node("Catimation"):
		var catimation = player_character.get_node("Catimation") as AnimatedSprite2D
		if catimation and catimation.sprite_frames:
			catimation.play("nap")
		else:
			print("Catimation node or sprite_frames not found!")
	else:
		print("Player character has no animation method or Catimation node.")

	# Nastavi začetno pozicijo mačke
	player_character.position = Vector2(0, -30)

	# Skrij health bar, če obstaja
	if player_character.has_node("PlayerHealthBar"):
		var health_bar = player_character.get_node("PlayerHealthBar")
		if health_bar:
			health_bar.visible = false
	
	return true
