extends CharacterBody2D

@onready var animated_sprite = $Catimation

var speed = 200
var is_walking = true

func _ready():
	animated_sprite.play("walk")

func _physics_process(_delta):
	if Input.is_action_just_pressed("pause"):
		is_walking = not is_walking
		if is_walking:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")
