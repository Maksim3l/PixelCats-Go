extends Node2D
@export var player_character: Node2D
@onready var treat = $"Organizer/UITop/Treat/value"
@onready var energy = $"Organizer/UITop/Energy/value"
@onready var gold = $"Organizer/UITop/Gold/value"

func _ready():
	randomize()
	
	var active_cat = CatHandler.get_active_cat()
	var global_data = GlobalDataHandler.global_data
	if not active_cat:
		print("No active cat found")
		return false
	
	if player_character.has_method("nap"):
		player_character.nap()
	
	player_character.position.x = -32
	player_character.position.y = -80
	
	energy.text = str(active_cat.max_energy) + "/" + str(active_cat.energy)
	gold.text = str(global_data.gold)
	treat.text = str(global_data.treat)
	
	return true
