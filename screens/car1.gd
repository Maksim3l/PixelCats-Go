extends CharacterBody2D

const TORNADO = preload("res://screens/tornado.tscn")
@onready var merge: Node2D = $".."

signal collision_detected


# Movement parameters
var speed = 100.0
var gravity = 980.0
var direction = Vector2(1, 0)  # Direction of automatic movement (right)

func _physics_process(delta):
	
	# Set constant horizontal velocity for automatic movement
	velocity.x = direction.x * speed
	
	# Apply movement
	move_and_slide()
	
	for i in get_slide_collision_count():
		emit_signal("collision_detected")
		spawn_tornado()


func spawn_tornado():
	print("collision")
	
