extends Camera2D

var speed = 150  # Changed from 00 to 150
@export var is_paused = false

func _process(delta):
	if not is_paused:
		var velocity = Vector2.ZERO
		
		# Check for input first, without limit checks
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
			
		# Apply speed if moving
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		
		# Calculate new position
		var new_position = position + velocity * delta
		
		# Apply limits after calculating movement
		if new_position.x < limit_left:
			new_position.x = limit_left
		if new_position.x > limit_right:
			new_position.x = limit_right
			
		# Update position
		position = new_position
