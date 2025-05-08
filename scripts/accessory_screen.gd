extends Node2D

@onready var player = $Organizer/CenterBG/player/Catimation
@onready var health_bar = $Organizer/CenterBG/player/PlayerHealthBar
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"

func _ready():
	
	var global_data = GlobalDataHandler.global_data
	gold.text = str(global_data.gold)


	if player and health_bar:
		player.play("idle")  
		health_bar.visible = false 
