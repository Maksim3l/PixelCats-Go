extends CharacterBody2D
class_name Enemy

@export var enemy_data: EnemyStats

var current_health: int
var target = null
var can_attack: bool = true
var battle = null

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer
@onready var nameLabel = $Name
@onready var titleLabel = $Title
@onready var animation_player = $AnimationPlayer
@onready var particles = $DamageParticles

var hit_shader_material = null
var stagger_tween = null
var is_staggering = false

func _ready():
	current_health = enemy_data.max_health
	
	sprite.sprite_frames.remove_frame('default', 0)
	sprite.sprite_frames.add_frame('default', enemy_data.texture, 0)
	
	if sprite:
		hit_shader_material = ShaderMaterial.new()
		hit_shader_material.shader = load("res://resources/hit_flash.gdshader")
		hit_shader_material.set_shader_parameter("flash_color", Color(1.0, 0.0, 0.0, 1.0))
		hit_shader_material.set_shader_parameter("flash_modifier", 0.0)
	
	if particles:
		particles.emitting = false
	
	health_bar.max_value = enemy_data.max_health
	health_bar.value = current_health
	attack_timer.wait_time = enemy_data.attack_cooldown
	nameLabel.text = enemy_data.name
	titleLabel.text = enemy_data.title

func _process(_delta):
	if target and can_attack:
		attack_target()

func attack_target():
	can_attack = false
	var damage = enemy_data.attack
	target.take_damage(damage)
	attack_timer.start()

func take_damage(amount):
	var actual_damage = max(1, amount - enemy_data.defense)
	current_health -= actual_damage
	health_bar.value = current_health
	
	stagger_effect()
	
	if current_health <= 0:
		die()

func stagger_effect():
	if is_staggering:
		return
		
	is_staggering = true
	
	apply_hit_flash()
	apply_stagger_movement()
	emit_damage_particles()
	
	await get_tree().create_timer(0.5).timeout
	if sprite != null and is_instance_valid(sprite) and sprite.material != null:
		sprite.material.set_shader_parameter("flash_modifier", 0.0)
	is_staggering = false

func apply_hit_flash():
	sprite.material = hit_shader_material
	
	if hit_shader_material != null:
		var flash_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		flash_tween.tween_property(hit_shader_material, "shader_parameter/flash_modifier", 1.0, 0.05)
		flash_tween.tween_property(hit_shader_material, "shader_parameter/flash_modifier", 0.0, 0.2)

func apply_stagger_movement():
	var push_direction = Vector2(1, 0)
	if target: 
		push_direction = (global_position - target.global_position).normalized()
	stagger_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	var original_position = position
	var original_rotation = rotation
	
	stagger_tween.tween_property(sprite, "position", position + push_direction * 10, 0.1)
	stagger_tween.tween_property(sprite, "position", original_position, 0.2)

	stagger_tween.parallel().tween_property(sprite, "rotation", original_rotation + 0.1, 0.1)
	stagger_tween.tween_property(sprite, "rotation", original_rotation, 0.2)

func emit_damage_particles():
	if particles:
		particles.amount = 8
		particles.lifetime = 0.5
		particles.explosiveness = 0.8
		particles.emitting = true

func die():
	battle.enemy_defeated(enemy_data.experience_reward, enemy_data.gold_reward)
	queue_free()

func _on_attack_timer_timeout():
	can_attack = true
