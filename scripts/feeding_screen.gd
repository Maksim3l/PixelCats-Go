extends Node2D

@onready var treat_label = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"
@export var player_character: Node2D

func _ready():
	MusicManager.play_main_music()
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
	
	energy.text = str(active_cat.energy) + "/" + str(active_cat.max_energy)
	gold.text = str(global_data.gold)
	update_treat_display(global_data.treat)

	# Pravilno poveži signal
	GlobalDataHandler.connect("treat_updated", Callable(self, "_on_treat_updated"))	
	return true
	
func update_treat_display(new_treat_value):
	treat_label.text = str(new_treat_value)
	
func _on_treat_updated(new_treat_value):
	print("Treat updated:", new_treat_value)
	update_treat_display(new_treat_value)
	
