extends CharacterBody2D
class_name Enemy

@export var enemy_data: EnemyStats

var current_health: int
var target = null
var can_attack: bool = true

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer

func _ready():
	current_health = enemy_data.max_health
	sprite.sprite_frames.remove_frame('default', 0)
	sprite.sprite_frames.add_frame('default', enemy_data.texture, 0)
	health_bar.max_value = enemy_data.max_health
	health_bar.value = current_health
	attack_timer.wait_time = enemy_data.attack_cooldown

func _process(delta):
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
	
	if current_health <= 0:
		die()

func die():
	var battle_system = get_parent()
	battle_system.enemy_defeated(enemy_data.experience_reward, enemy_data.gold_reward)
	queue_free()

func _on_attack_timer_timeout():
	can_attack = true
