extends Node2D

var speed = 100
var is_paused = false

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused 
	
	if not is_paused:
		var velocity = Vector2.ZERO
		velocity.x += 1
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		position += velocity * delta
