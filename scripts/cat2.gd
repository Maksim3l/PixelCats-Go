extends CharacterBody2D
# Movement parameters
var speed = 70.0
var gravity = 980.0
var direction = Vector2(-1, 0)  # Direction of automatic movement (right)
var is_stopped = false 

func _physics_process(delta):
	if is_stopped:
		velocity = Vector2.ZERO
	else:
		velocity.x = direction.x * speed
	
	# Apply movement
	move_and_slide()

# Function to stop movement
func stop_movement():
	is_stopped = true
	velocity = Vector2.ZERO
