extends Node2D

@onready var character_1: CharacterBody2D = $Character1
@onready var character_2: CharacterBody2D = $Character2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player health: ", character_1.health)
	print("Player power: ", character_1.power)
	print("Player health: ", character_2.health)
	print("Player power: ", character_2.power)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
