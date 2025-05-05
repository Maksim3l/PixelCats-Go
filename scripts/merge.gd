extends Node2D
const TORNADO = preload("res://screens/tornado.tscn")
@onready var cat1: CharacterBody2D = $CharacterBody2D
@onready var cat2: CharacterBody2D = $CharacterBody2D2
@onready var tornado: CharacterBody2D = $tornado
@onready var timer: Timer = $Timer

var selected_cats = []

# Called when the node enters the scene tree for the first time.
func _ready():
	tornado.hide()
	cat1.connect("collision_detected", Callable(self, "_on_cat_collision"))
	if not timer.timeout.is_connected(_on_tornado_timeout):
		timer.timeout.connect(_on_tornado_timeout)
	print("Recieved cats", selected_cats)
	
	
func _process(delta: float) -> void:
	pass


func _on_cat_collision():
	# Hide the cat
	cat1.hide()
	cat2.queue_free()
	
	tornado.show()
	
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.start()
	

	
func _on_tornado_timeout():
	print("Tornado will be hidden")
	tornado.hide()
	cat1.visible = true
	get_tree().change_scene_to_file("res://screens/battle.tscn")

	
