# Player.gd
extends CharacterBody2D

enum ArenaLevel {BATHROOM, BEDROOM, LIVINGROOM, KITCHEN, GARDEN, BOSS}

var cat_name: String = "Whiskers"
var cat_sprite: String = "res://characters/main/main.png"

var max_health: int = 100
var current_health: int = 100
var attack: int = 10
var defense: int = 5
var gold: int = 0
var max_energy: int = 3
var energy: int = 3
var experience: int = 0
var level: int = 1
var temp_attack: int = 0
var temp_defense: int = 0

@onready var arena_level: int = ArenaLevel.BATHROOM
@onready var health_bar = $PlayerHealthBar
@onready var attack_timer = $AttackTimer
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Catimation
@onready var particles = $DamageParticles
@onready var attack_sfx_player: AudioStreamPlayer = $AttackSfxPlayer 
@onready var head_slot_sprite: AnimatedSprite2D = $HeadSlot
@onready var body_slot_sprite: AnimatedSprite2D = $BodySlot
var player_attack_sound = preload("res://assets/soundFX/main-hit.mp3")
var _previous_animation_before_stagger: String = "idle" 
@onready var stagger_cleanup_timer: Timer = Timer.new()

@onready var win = $stage_clear

var current_head_sf_path: String = "" 
var current_body_sf_path: String = ""
var can_attack: bool = true
var current_target = null
var hit_shader_material = null
var stagger_tween = null
var is_staggering = false

func _ready():
	
	if health_bar:
		health_bar.set_max_health(max_health)
		health_bar.set_current_health(current_health)
	
	if sprite:
		hit_shader_material = ShaderMaterial.new()
		hit_shader_material.shader = load("res://resources/hit_flash.gdshader")
		hit_shader_material.set_shader_parameter("flash_color", Color(1.0, 0.0, 0.0, 1.0))
		hit_shader_material.set_shader_parameter("flash_modifier", 0.0)
	
	if particles:
		particles.emitting = false
		
	head_slot_sprite.visible = false
	body_slot_sprite.visible = false
	
	stagger_cleanup_timer.name = "StaggerCleanupTimer"
	stagger_cleanup_timer.one_shot = true
	if not stagger_cleanup_timer.is_connected("timeout", Callable(self, "_perform_stagger_cleanup")):
		stagger_cleanup_timer.connect("timeout", Callable(self, "_perform_stagger_cleanup"))
	add_child(stagger_cleanup_timer) 
	
	load_game()
	play_animation("idle")
	
	
func play_animation(animation_name: String):
	# Predvajaj na osnovnem spritu mačke
	var cat_played_fallback = false
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
		cat_played_fallback = true
	else:
		printerr("Catimation sprite in Player.gd does not have animation: " + animation_name + " or idle.")

	var equipment_anim_name = animation_name
	if cat_played_fallback and animation_name != "idle":
		equipment_anim_name = "idle" 
		
	# Predvajaj na slotu za glavo, če je viden in ima ustrezno animacijo
	if head_slot_sprite.visible and head_slot_sprite.sprite_frames:
		if head_slot_sprite.sprite_frames.has_animation(animation_name):
			head_slot_sprite.play(animation_name)
		elif head_slot_sprite.sprite_frames.has_animation("idle"):
			head_slot_sprite.play("idle")
		elif head_slot_sprite.sprite_frames.has_animation("default"):
			head_slot_sprite.play("default")

	# Predvajaj na slotu za telo, če je viden in ima ustrezno animacijo
	if body_slot_sprite.visible and body_slot_sprite.sprite_frames:
		if body_slot_sprite.sprite_frames.has_animation(animation_name):
			body_slot_sprite.play(animation_name)
		elif body_slot_sprite.sprite_frames.has_animation("idle"):
			body_slot_sprite.play("idle")
		elif head_slot_sprite.sprite_frames.has_animation("default"):
			head_slot_sprite.play("default")
			
func _input(event):
	if event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()
	elif event.is_action_pressed("switch_cat"):
		switch_to_next_cat()


func switch_to_next_cat():
	var next_index = (CatHandler.cat_manager.active_cat_index + 1) % CatHandler.get_all_cats().size()
	CatHandler.switch_cat(next_index)
	
	var cat_data = CatHandler.get_active_cat()
	cat_data.apply_to_cat(self)
	

func _process(delta):
	if current_target and can_attack:
		attack_target()

func attack_target():
	can_attack = false
	
	if sprite.is_connected("animation_finished", _on_attack_animation_finished):
		sprite.disconnect("animation_finished", _on_attack_animation_finished)
	
	if sprite.is_connected("frame_changed", _on_frame_changed):
		sprite.disconnect("frame_changed", _on_frame_changed)
	
	sprite.connect("animation_finished", Callable(self, "_on_attack_animation_finished"), CONNECT_ONE_SHOT)
	sprite.connect("frame_changed", _on_frame_changed)
	play_animation("attack")

func _on_frame_changed():
	if sprite.animation == "attack" and sprite.frame == 4:
		var damage = attack + temp_attack
		
		print("atk: ", attack, "; tmp_atk: ", temp_attack)
		
		if current_target and current_target.has_method("take_damage"):
			current_target.take_damage(damage)
			
		if attack_sfx_player and player_attack_sound:
			attack_sfx_player.stream = player_attack_sound
			attack_sfx_player.play() 
		attack_timer.start()

		if sprite.is_connected("frame_changed", Callable(self, "_on_frame_changed")):
			sprite.disconnect("frame_changed", Callable(self, "_on_frame_changed"))
	
func _on_attack_animation_finished():
	if sprite.animation == "attack":
		play_animation("idle")
		if sprite.is_connected("animation_finished", _on_attack_animation_finished):
			sprite.disconnect("animation_finished", _on_attack_animation_finished)
		
		if sprite.is_connected("frame_changed", _on_frame_changed):
			sprite.disconnect("frame_changed", _on_frame_changed)
	
func take_damage(amount):
	var actual_damage = max(1, amount - (defense + temp_defense))
	current_health -= actual_damage
	if current_health < 0:
		current_health = 0
	
	if health_bar:
		health_bar.set_current_health(current_health)
	
	print("def: ", defense, "; tmp_def: ", temp_defense)
	stagger_effect()
	
	if current_health <= 0:
		die()

func stagger_effect():
	if is_staggering:
		return
		
	is_staggering = true
	
	if sprite and sprite.is_playing() and sprite.animation != "stagger" and sprite.animation != "death": 
		_previous_animation_before_stagger = sprite.animation
	elif sprite and not sprite.is_playing() and sprite.animation: 
		_previous_animation_before_stagger = sprite.animation
	else:
		_previous_animation_before_stagger = "idle"

	play_animation("stagger")
	
	apply_hit_flash()
	apply_stagger_movement()
	emit_damage_particles()
	
	var stagger_duration = 0.5 
	if sprite and is_instance_valid(sprite) and \
	   sprite.sprite_frames and sprite.sprite_frames.has_animation("stagger"):
		
		var anim_name = "stagger"
		
		var anim_is_looping = sprite.sprite_frames.get_animation_loop(anim_name)

		if not anim_is_looping: 
			var frame_count = sprite.sprite_frames.get_frame_count(anim_name)
			var anim_speed_fps = sprite.sprite_frames.get_animation_speed(anim_name) 
			
			if frame_count > 0 and anim_speed_fps > 0:
				var total_relative_duration_units = 0.0
				for i in range(frame_count):
					total_relative_duration_units += sprite.sprite_frames.get_frame_duration(anim_name, i) 
				var calculated_anim_length = total_relative_duration_units / anim_speed_fps
				stagger_duration = max(calculated_anim_length, 0.3)
	stagger_cleanup_timer.start(stagger_duration)
func _perform_stagger_cleanup():
	if not is_staggering: 
		return

	if sprite != null and is_instance_valid(sprite) and sprite.material == hit_shader_material:
		hit_shader_material.set_shader_parameter("flash_modifier", 0.0)

	is_staggering = false

	var current_sprite_anim = ""
	if sprite and is_instance_valid(sprite):
		current_sprite_anim = sprite.animation
	
	if current_sprite_anim != "death": 
		if current_sprite_anim == "stagger" or (sprite and is_instance_valid(sprite) and not sprite.is_playing()):
			play_animation(_previous_animation_before_stagger)

func apply_hit_flash():
	sprite.material = hit_shader_material
	
	if hit_shader_material != null:
		var flash_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		flash_tween.tween_property(hit_shader_material, "shader_parameter/flash_modifier", 1.0, 0.05)
		flash_tween.tween_property(hit_shader_material, "shader_parameter/flash_modifier", 0.0, 0.2)

func apply_stagger_movement():
	var sprites_to_move = []
	if sprite and is_instance_valid(sprite): 
		sprites_to_move.append(sprite)
	if head_slot_sprite and is_instance_valid(head_slot_sprite) and head_slot_sprite.visible and head_slot_sprite.sprite_frames:
		sprites_to_move.append(head_slot_sprite)
	if body_slot_sprite and is_instance_valid(body_slot_sprite) and body_slot_sprite.visible and body_slot_sprite.sprite_frames:
		sprites_to_move.append(body_slot_sprite)

	if sprites_to_move.is_empty(): # Če ni nobenega sprita za premakniti, končaj.
		return

	var push_direction = Vector2.LEFT
	var push_amount = 10.0          # Kako daleč se sprite odbije (v pikslih)
	var push_duration = 0.1         # Kako hitro se sprite odbije (v sekundah)
	var return_duration = 0.2       # Kako hitro se sprite vrne (v sekundah)

	if current_target and is_instance_valid(current_target):
		var direction_away_from_target = (global_position - current_target.global_position).normalized()
		if direction_away_from_target != Vector2.ZERO:
			push_direction = direction_away_from_target
	
	if push_direction == Vector2.ZERO: 
		push_direction = Vector2.LEFT

	for s_node in sprites_to_move:
		var individual_tween = create_tween().set_parallel(false) 
		
		var original_node_position = s_node.position 
		individual_tween.tween_property(s_node, "position", original_node_position + push_direction * push_amount, push_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		individual_tween.tween_property(s_node, "position", original_node_position, return_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN) 

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
	GlobalDataHandler.add_gold(amount)

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


func set_equipment(slot_type: String, item_sf_path: String):
	var target_slot_sprite: AnimatedSprite2D
	var current_path_var_to_update_in_cat_data: String 

	if slot_type == "head":
		target_slot_sprite = head_slot_sprite
		current_head_sf_path = item_sf_path
		current_path_var_to_update_in_cat_data = "equipped_head_sf_path"
	elif slot_type == "body":
		target_slot_sprite = body_slot_sprite
		current_body_sf_path = item_sf_path
		current_path_var_to_update_in_cat_data = "equipped_body_sf_path"
	else:
		printerr("Unknown equipment slot type: " + slot_type)
		return

	var previous_animation_playing_on_slot = ""
	if target_slot_sprite.sprite_frames and target_slot_sprite.is_playing():
		previous_animation_playing_on_slot = target_slot_sprite.animation


	if item_sf_path != "" and item_sf_path != null:
		var sf_resource = load(item_sf_path)
		if sf_resource is SpriteFrames:
			target_slot_sprite.sprite_frames = sf_resource
			target_slot_sprite.visible = true
			
			var anim_to_set_on_slot =sprite.animation # Privzeto poskusi trenutno animacijo mačke
			if not target_slot_sprite.sprite_frames.has_animation(anim_to_set_on_slot):
				if target_slot_sprite.sprite_frames.has_animation("idle"):
					anim_to_set_on_slot = "idle"
				elif target_slot_sprite.sprite_frames.has_animation("default"):
					anim_to_set_on_slot = "default"
				else: # Če nima ničesar od tega, vzemi prvo animacijo iz seznama
					var anims = target_slot_sprite.sprite_frames.get_animation_names()
					if anims.size() > 0: anim_to_set_on_slot = anims[0]
					else: anim_to_set_on_slot = "" # Ni animacij

			if anim_to_set_on_slot != "" and target_slot_sprite.sprite_frames.has_animation(anim_to_set_on_slot):
				if not target_slot_sprite.is_playing() or target_slot_sprite.animation != anim_to_set_on_slot or previous_animation_playing_on_slot == "":
					target_slot_sprite.play(anim_to_set_on_slot)
		else:
			printerr("Failed to load SpriteFrames for " + slot_type + ": " + item_sf_path)
			target_slot_sprite.sprite_frames = null
			target_slot_sprite.visible = false
	else: 
		target_slot_sprite.sprite_frames = null
		target_slot_sprite.visible = false

	var active_cat_data = CatHandler.get_active_cat()
	if active_cat_data and current_path_var_to_update_in_cat_data != "":
		active_cat_data.set(current_path_var_to_update_in_cat_data, item_sf_path)
		
func save_game():
	var active_cat_data = CatData.from_cat(self)
	active_cat_data.equipped_head_sf_path = current_head_sf_path
	active_cat_data.equipped_body_sf_path = current_body_sf_path
	var all_cats = CatHandler.get_all_cats()
	all_cats[CatHandler.cat_manager.active_cat_index] = active_cat_data
	
	var success = CatHandler.save_cat_manager()
	if success:
		print("Game saved successfully with", CatHandler.get_all_cats().size(), "cats")
	return success

func load_game():
	var active_cat_data = CatHandler.get_active_cat()
	active_cat_data.apply_to_cat(self)
	current_head_sf_path = active_cat_data.equipped_head_sf_path
	current_body_sf_path = active_cat_data.equipped_body_sf_path
	health_bar.value = current_health
	print("Game loaded successfully with", CatHandler.get_all_cats().size(), "cats")
	return true


func _on_battle_arena_difficulty_increased(new_difficulty):
	arena_level = new_difficulty
	win.play()
	

func walk():
	play_animation("walk")
	
func nap():
	play_animation("nap")
	#health_bar.visible = false
	
# add a new cat
func add_new_cat(cat_name: String, cat_sprite: String) -> void:
	var new_cat = CatData.new(
		cat_name,
		cat_sprite
	)
	CatHandler.cat_manager.cats.append(new_cat)
	print("Added new cat", cat_name)
