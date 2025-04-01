extends Node2D

var speed = 100
var is_paused = false

func _process(delta):	
	if not is_paused:
		var velocity = Vector2.ZERO
		velocity.x += 1
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		position += velocity * delta

func _on_battle_arena_battle_started():
	is_paused = true
	
func _on_battle_arena_battle_ended():
	is_paused = false
