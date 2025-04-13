# Player.gd
extends CharacterBody2D

var save_file_path = "res://data/"
var save_file_name = "PlayerSave.tres"
var playerData = PlayerData.new()

enum ArenaLevel {BATHROOM, BEDROOM, LIVINGROOM, KITCHEN, GARDEN, BOSS}

var max_health: int = playerData.max_health
var current_health: int = playerData.current_health
var attack: int = playerData.attack
var defense: int = playerData.defense
var gold: int = playerData.gold
var energy: int = playerData.energy
var experience: int = playerData.experience
var level: int = playerData.level

@onready var arena_level: int = ArenaLevel.BATHROOM
@onready var health_bar = $HealthBar
@onready var attack_timer = $AttackTimer
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Catimation
@onready var particles = $DamageParticles

var can_attack: bool = true
var current_target = null
var hit_shader_material = null
var stagger_tween = null
var is_staggering = false

func _ready():
	health_bar.value = current_health
	health_bar.max_value = max_health
	
	if sprite:
		hit_shader_material = ShaderMaterial.new()
		hit_shader_material.shader = load("res://resources/hit_flash.gdshader")
		hit_shader_material.set_shader_parameter("flash_color", Color(1.0, 0.0, 0.0, 1.0))
		hit_shader_material.set_shader_parameter("flash_modifier", 0.0)
	
	if particles:
		particles.emitting = false
	
	load_game()
	
func _input(event):
	if event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()

func _process(delta):
	if current_target and can_attack:
		attack_target()

func attack_target():
	can_attack = false
	
	if sprite.is_connected("animation_finished", _on_attack_animation_finished):
		sprite.disconnect("animation_finished", _on_attack_animation_finished)
	
	if sprite.is_connected("frame_changed", _on_frame_changed):
		sprite.disconnect("frame_changed", _on_frame_changed)
	
	sprite.connect("animation_finished", _on_attack_animation_finished)
	sprite.connect("frame_changed", _on_frame_changed)
	sprite.play("attack")

func _on_frame_changed():
	if sprite.animation == "attack" and sprite.frame == 4:
		var damage = attack
		if current_target and current_target.has_method("take_damage"):
			current_target.take_damage(damage)
		attack_timer.start()

		if sprite.is_connected("frame_changed", _on_frame_changed):
			sprite.disconnect("frame_changed", _on_frame_changed)
	
func _on_attack_animation_finished():
	if sprite.animation == "attack":
		sprite.play("idle")
		if sprite.is_connected("animation_finished", _on_attack_animation_finished):
			sprite.disconnect("animation_finished", _on_attack_animation_finished)
		
		if sprite.is_connected("frame_changed", _on_frame_changed):
			sprite.disconnect("frame_changed", _on_frame_changed)
	
func take_damage(amount):
	var actual_damage = max(1, amount - defense)
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
	var push_direction = Vector2(-1, 0)
	if current_target: 
		push_direction = (global_position - current_target.global_position).normalized()
	stagger_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	var original_position = position
	var original_rotation = rotation
	
	stagger_tween.tween_property(sprite, "position", position + push_direction * 10, 0.1)
	stagger_tween.tween_property(sprite, "position", original_position, 0.2)

	stagger_tween.parallel().tween_property(sprite, "rotation", original_rotation - 0.1, 0.1)
	stagger_tween.tween_property(sprite, "rotation", original_rotation, 0.2)

func emit_damage_particles():
	if particles:
		particles.amount = 8
		particles.lifetime = 0.5
		particles.explosiveness = 0.8
		particles.emitting = true

func die():
	energy -= 1
	save_game()
	get_tree().change_scene_to_file("res://screens/idle_screen.tscn")
	

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
	
func save_game():
	# Create PlayerData from current player state
	var data = PlayerData.from_player(self)
	
	# Create directory if it doesn't exist (this works only in editor)
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")
	
	# Save the resource to disk
	var error = ResourceSaver.save(data, save_file_path + save_file_name)
	if error != OK:
		print("Error saving game: ", error)
		return false
	
	print("Game saved successfully to: ", save_file_path + save_file_name)
	return true

func load_game():
	if not FileAccess.file_exists(save_file_path + save_file_name):
		print("No save file found")
		return false
	
	# Load the resource
	var data = ResourceLoader.load(save_file_path + save_file_name)
	if not data:
		print("Error loading save file")
		return false
	
	# Apply the data to the player
	data.apply_to_player(self)
	
	current_health = 2
	health_bar.value = current_health
	
	print("Game loaded successfully")
	return true


func _on_battle_arena_difficulty_increased(new_difficulty):
	arena_level = new_difficulty
	

func walk():
	sprite.play("walk")
	
func nap():
	sprite.play("nap")
	#health_bar.visible = false
