extends Node2D
@export var player_character: Node2D
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"
var save_file_path = "res://data/"
var save_file_name = "CatManager.tres" 
var cat_manager = CatManager.new()


func _ready():
	randomize()
	
	# Try to load the CatManager resource
	if not FileAccess.file_exists(save_file_path + save_file_name):
		print("No save file found")
		return false
	
	# Load the CatManager resource
	var loaded_data = ResourceLoader.load(save_file_path + save_file_name)
	if not loaded_data or not loaded_data is CatManager:
		print("Error loading CatManager or invalid format")
		return false
		
	cat_manager = loaded_data
	
	# Get the active cat data from the cat manager
	var active_cat = cat_manager.get_active_cat()
	if not active_cat:
		print("No active cat found")
		return false
	
	# Set up the player character
	if player_character.has_method("nap"):
		player_character.nap()
	
	player_character.position.x = -32
	player_character.position.y = -80
	
	# Update UI with the active cat's data
	energy.text = "3/" + str(active_cat.energy)
	gold.text = str(active_cat.gold)
	
# Skrij health bar ob zagonu idle screen-a
	if $Organizer/CenterBG/ParallaxBackground/ParallaxLayer3/player.has_node("PlayerHealthBar"):
		$Organizer/CenterBG/ParallaxBackground/ParallaxLayer3/player/PlayerHealthBar.visible = false
	
	return true
