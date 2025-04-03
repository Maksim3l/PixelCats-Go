extends CharacterBody2D

# Movement parameters
var speed = 70.0
var gravity = 980.0
var direction = Vector2(-1, 0)  # Direction of automatic movement (right)

func _physics_process(delta):
	
	# Set constant horizontal velocity for automatic movement
	velocity.x = direction.x * speed
	
	# Apply movement
	move_and_slide()
	
