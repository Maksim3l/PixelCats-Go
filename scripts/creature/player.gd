# Player.gd
extends CharacterBody2D

var max_health: int = 100
var current_health: int = max_health
var attack: int = 10
var defense: int = 5
var speed: int = 10
var gold: int = 0
var experience: int = 0
var level: int = 1

@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer

var can_attack: bool = true
var current_target = null

func _ready():
	health_bar.value = current_health
	health_bar.max_value = max_health

func _process(delta):
	if current_target and can_attack:
		attack_target()

func attack_target():
	can_attack = false
	var damage = attack
	if current_target and current_target.has_method("take_damage"):
		current_target.take_damage(damage)
	attack_timer.start()

func take_damage(amount):
	var actual_damage = max(1, amount - defense)
	current_health -= actual_damage
	health_bar.value = current_health
	
	if current_health <= 0:
		die()

func die():
	# Game over logic
	pass

func add_experience(amount):
	experience += amount
	check_level_up()

func add_gold(amount):
	gold += amount

func check_level_up():
	var exp_needed = level * 100  # Simple formula, adjust as needed
	if experience >= exp_needed:
		level_up()

func level_up():
	level += 1
	max_health += 10
	current_health = max_health
	attack += 2
	defense += 1

func _on_attack_timer_timeout():
	can_attack = true
