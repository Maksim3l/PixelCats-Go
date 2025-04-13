extends Node2D

@export var player_character: Node2D
@onready var energy = $"Organizer/UITop/Energy/value"
@onready var gold = $"Organizer/UITop/Gold/value"
var save_file_path = "res://data/"
var save_file_name = "PlayerSave.tres"
var playerData = PlayerData.new()

func _ready():
	randomize()
	if not FileAccess.file_exists(save_file_path + save_file_name):
		print("No save file found")
		return false
	
	# Load the resource
	var data = ResourceLoader.load(save_file_path + save_file_name)
	if not data:
		print("Error loading save file")
		return false
	if player_character.has_method("nap"):
		player_character.nap()
	player_character.position.x = -32
	player_character.position.y = -80
	energy.text = "3/" + str(data.energy)
	gold.text = str(data.gold)
	
