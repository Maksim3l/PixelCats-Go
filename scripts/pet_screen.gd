extends Node2D
@onready var treat = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"

func _ready():
	
	var global_data = GlobalDataHandler.global_data

	gold.text = str(global_data.gold)

	
	return true
