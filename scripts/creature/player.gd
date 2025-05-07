# Player.gd
extends CharacterBody2D

var save_file_path = "res://data/"
var save_file_name = "CatManager.tres"
var cat_manager = CatManager.new()

enum ArenaLevel {BATHROOM, BEDROOM, LIVINGROOM, KITCHEN, GARDEN, BOSS}

# Cat identity properties
var cat_name: String = "Whiskers"
var cat_sprite: String = "res://characters/main/main.png"

var max_health: int = 100
var current_health: int = 100
var attack: int = 10
var defense: int = 5
var gold: int = 0
var energy: int = 3
var experience: int = 0
var level: int = 1

@onready var arena_level: int = ArenaLevel.BATHROOM
@onready var health_bar = $PlayerHealthBar
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
	#health_bar.value = current_health
	#health_bar.max_value = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.update_label()
	
	if sprite:
		hit_shader_material = ShaderMaterial.new()
		hit_shader_material.shader = load("res://resources/hit_flash.gdshader")
		hit_shader_material.set_shader_parameter("flash_color", Color(1.0, 0.0, 0.0, 1.0))
		hit_shader_material.set_shader_parameter("flash_modifier", 0.0)
	
	if particles:
		particles.emitting = false
		
	var load_success = load_game()
	
	# If loading failed, create a new cat and save it
	if !load_success:
		print("Creating new cat and saving...")
		cat_manager = CatManager.new()
		var new_cat = PlayerData.new()
		cat_manager.cats = [new_cat]
		cat_manager.active_cat_index = 0
		save_game()
	
	
	
func _input(event):
	if event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()
	elif event.is_action_pressed("switch_cat"):
		switch_to_next_cat()


func switch_to_next_cat():
	var next_index = (cat_manager.active_cat_index + 1) % cat_manager.cats.size()
	cat_manager.switch_cat(next_index)
	
	var cat_data = cat_manager.get_active_cat()
	cat_data.apply_to_player(self)
	

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
	
	if current_health < 0:
		current_health = 0
	
	# Posodobi health bar
	if health_bar:
		health_bar.value = current_health
		health_bar.update_label()
	
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
	# update active cat data in the manager
	var active_cat_data = PlayerData.from_player(self)
	cat_manager.cats[cat_manager.active_cat_index] = active_cat_data
	
	# save cat manager
	var save_dir = "res://data/"
	var save_filename = "CatManager.tres"
	var success = cat_manager.save_cats(save_file_path + save_file_name)
	if success:
		print("Game saved successfully with", cat_manager.cats.size(), "cats")
	return success

func load_game():
	cat_manager = CatManager.load_cats(save_file_path + save_file_name)
	
	var active_cat_data = cat_manager.get_active_cat()
	active_cat_data.apply_to_player(self)
	
	# ensure good health
	current_health = 100
	health_bar.value = current_health

	print("Game loaded successfully with", cat_manager.cats.size(), "cats")
	return true


func _on_battle_arena_difficulty_increased(new_difficulty):
	arena_level = new_difficulty
	

func walk():
	sprite.play("walk")
	
func nap():
	sprite.play("nap")
	#health_bar.visible = false
	
# add a new cat
func add_new_cat(cat_name: String, cat_sprite: String) -> void:
	var new_cat = PlayerData.new(
		cat_name,
		cat_sprite
	)
	cat_manager.cats.append(new_cat)
	print("Added new cat", cat_name)
