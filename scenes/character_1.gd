extends CharacterBody2D

@export var speed = 60.0
var direction = Vector2(1, 0) # Start moving right
@onready var tornado: CharacterBody2D = $"../Tornado"
@onready var timer: Timer = $"../Timer"
var collision_enabled = true  # Flag to track if collision detection is enabled
@onready var new_cat: CharacterBody2D = $"../NewCat"

var health = 30
var power = 40

func _ready():
	# Connect the timer signal once when the scene starts
	if not timer.timeout.is_connected(_on_tornado_timeout):
		timer.timeout.connect(_on_tornado_timeout)
	# Make sure tornado is initially hidden
	tornado.hide()
	new_cat.hide()

func _physics_process(delta):
	# Only process collisions if enabled
	if collision_enabled:
		velocity = direction * speed
		var collision = move_and_collide(velocity * delta)
		if collision:
			# Collision event
			_on_collision()
	else:
		# If collision is disabled, still update position but don't check collisions
		position += direction * speed * delta

func _on_collision():
	hide()
	tornado.show()
	
	# Disable further collision detection
	collision_enabled = false
	
	# Start the 5-second timer
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.start()
	
	# Debug print to confirm timer started
	print("Timer started, tornado should hide in 5 seconds")

func _on_tornado_timeout():
	print("Tornado will be hidden")
	tornado.hide()
	new_cat.show()
	
	# Optionally, you can re-enable collision here if needed
	# collision_enabled = true
