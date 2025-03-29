extends Node2D

@onready var character_1: CharacterBody2D = $Character1
@onready var character_2: CharacterBody2D = $Character2
@onready var new_cat: CharacterBody2D = $NewCat


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player health: ", character_1.health)
	print("Player power: ", character_1.power)
	print("Player health: ", character_2.health)
	print("Player power: ", character_2.power)
	calculate_stats()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func calculate_stats():
	var combined_health = character_1.health + character_2.health
	var combined_power = character_1.power + character_2.power
	
	new_cat.health = combined_health
	new_cat.power = combined_power
	
