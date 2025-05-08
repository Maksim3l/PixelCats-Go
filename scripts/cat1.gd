extends CharacterBody2D

const TORNADO = preload("res://screens/tornado.tscn")
@onready var merge: Node2D = $".."
signal collision_detected

var speed = 50.0
var gravity = 980.0
var direction = Vector2(1, 0)  
var is_stopped = false

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# No boost_stats here anymore
	# Boost stats logic has been removed as per your request
	pass

func _physics_process(delta):
	# Check if movement should be stopped
	if is_stopped:
		velocity = Vector2.ZERO
		# Set the animation to idle when stopped
	else:
		# Set constant horizontal velocity for automatic movement
		velocity.x = direction.x * speed
		# Set the animation to walking when moving
	
	# Apply movement
	move_and_slide()

	# Check for collisions only if we're not already stopped
	if not is_stopped:
		for i in get_slide_collision_count():
			is_stopped = true  # Stop this cat
			emit_signal("collision_detected")  # Signal the parent
			spawn_tornado()
			break  # Only need to emit once

func spawn_tornado():
	print("collision")

# Function to stop movement
func stop_movement():
	is_stopped = true
	velocity = Vector2.ZERO
	# Set the animation to idle when stopped
