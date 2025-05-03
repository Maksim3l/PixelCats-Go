extends CPUParticles2D

func _ready():
	emitting = false
	one_shot = true
	explosiveness = 0.8
	
	amount = 8
	lifetime = 0.5
	lifetime_randomness = 0.3
	
	direction = Vector2(0, -1)
	spread = 60.0
	gravity = Vector2(0, 300)
	initial_velocity_min = 50.0
	initial_velocity_max = 100.0
	
	color = Color(1.0, 0.3, 0.3, 1.0)
	emission_shape = EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 5.0
