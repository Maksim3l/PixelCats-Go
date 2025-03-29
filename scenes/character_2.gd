extends CharacterBody2D

@export var speed = 60.0
var direction = Vector2(-1, 0) # Start moving right

var health = 30
var power = 60

func _physics_process(delta):
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)

	if collision:
		#Collision event
		_on_collision(collision.get_collider())

func _on_collision(collider):
	hide()
