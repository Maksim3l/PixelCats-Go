extends Node2D
@onready var audio: AudioStreamPlayer2D = $Organizer/BackButton/AudioStreamPlayer2D
@onready var audio1: AudioStreamPlayer2D = $Organizer/ContinueButton/AudioStreamPlayer2D
@onready var continue_button: Button = $Organizer/ContinueButton
@onready var back_button: Button = $Organizer/BackButton
@onready var cats_list: HBoxContainer = $Organizer/CatList2

# Track selected cats
var selected_cats = []
var max_cats = 2
var font_file
# To store cat sprite nodes for selection tracking
var cat_sprite_nodes = []

func _ready():
	MusicManager.play_main_music()
	font_file = preload("res://resources/pixel_sans.ttf")
	continue_button.add_theme_font_override("font", font_file)
	continue_button.add_theme_font_size_override("font_size", 5)

	back_button.add_theme_font_override("font", font_file)
	back_button.add_theme_font_size_override("font_size", 5)
	#print("Back button position:", back_button.position, " size:", back_button.size)
	#print("Continue button position:", continue_button.position, " size:", continue_button.size)

	# Clear existing list and populate with cat sprites
	populate_cats_list()

	continue_button.connect("pressed", Callable(self, "_on_continue_button_pressed"))
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	continue_button.disabled = true

func populate_cats_list():
	# Clear existing list items
	for child in cats_list.get_children():
		child.queue_free()

	# Clear tracking arrays
	selected_cats = []
	cat_sprite_nodes = []

	var all_cats = CatHandler.get_all_cats()

	# Create a container for layout of sprites
	var container = Control.new()
	container.custom_minimum_size = Vector2(cats_list.size.x, 200)
	#print("Container created with size: ", container.custom_minimum_size)
	cats_list.add_child(container)

	# Log the container's global position
	#print("Container global position: ", container.global_position)
	
	# Calculate container size for placement calculations
	var container_rect = container.get_rect()
	var container_size = container_rect.size
	#print("Container rect size: ", container_size)

	var cat_size = Vector2(30, 30)
	print("Total cats to place: ", all_cats.size())

	for i in range(all_cats.size()):
		var cat = all_cats[i]
		#print("Placing cat #", i, " (", cat.cat_name, ")")

		# Create cat sprite
		var cat_button = TextureButton.new()
		cat_button.ignore_texture_size = true
		cat_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		cat_button.custom_minimum_size = Vector2(25, 25)
		
		cat_button.modulate = Color(1, 1, 1, 0.4)

		# Load sprite texture
		if cat.cat_sprite and ResourceLoader.exists(cat.cat_sprite):
			cat_button.texture_normal = load(cat.cat_sprite)
		else:
			var placeholder = ColorRect.new()
			placeholder.color = Color(0.8, 0.2, 0.2)
			placeholder.custom_minimum_size = Vector2(25, 25)
			cat_button.add_child(placeholder)

		var name_label = Label.new()
		name_label.text = cat.cat_name
		name_label.add_theme_font_override("font", font_file)
		name_label.add_theme_font_size_override("font_size", 2)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		
		cat_sprite_nodes.append({"button": cat_button})

		# Connect button press
		cat_button.connect("pressed", Callable(self, "_on_cat_button_pressed").bind(i))

		# Find non-overlapping position with logging
		var position = find_non_overlapping_position(container, cat_size)
		print("Cat #", i, " position: ", position)
		
		# Check if position is outside container bounds
		if position.x < 0 || position.x > container_size.x - cat_size.x || position.y < 0 || position.y > container_size.y - cat_size.y:
			print("WARNING: Cat #", i, " positioned outside container bounds!")
		
		cat_button.position = position

		# hold the button and label
		var vbox = VBoxContainer.new()
		vbox.position = position
		vbox.add_child(cat_button)
		vbox.add_child(name_label)

		container.add_child(vbox)
		
		# Log the final global position of the cat
		#print("Cat #", i, " global position: ", vbox.global_position)
		
func find_non_overlapping_position(container, cat_size):
	var max_attempts = 50
	var attempts = 0
	
	var container_rect = container.get_rect()
	var container_size = container_rect.size
	#print("Finding position in container of size: ", container_size)
	
	# Define safe area within container with more margin at the bottom
	var margin_top = 50
	var margin_sides = 5
	var margin_bottom = 50  
	
	var min_x = margin_sides
	var max_x = container_size.x - cat_size.x - margin_sides
	var min_y = margin_top  
	var max_y = container_size.y - cat_size.y - margin_bottom  # More space at bottom
	
	#print("Safe area for cat placement: X(", min_x, "-", max_x, ") Y(", min_y, "-", max_y, ")")
	
	# Safety check - if container is too small
	if max_x <= min_x || max_y <= min_y:
		print("ERROR: Container too small for cat placement!")
		# Use a safe default position in the upper area
		return Vector2(5, 5)
	
	while attempts < max_attempts:
		# Generate random position - prioritize upper part of screen
		var random_x = randf_range(min_x, max_x)
		# Use weighted random to favor the upper part of the screen
		var random_y
		if randf() < 0.7:  # 70% chance to be in upper half
			random_y = randf_range(min_y, min_y + (max_y - min_y) / 2)
		else:
			random_y = randf_range(min_y, max_y)
			
		var test_position = Vector2(random_x, random_y)
		
		var overlapping = false
		for child in container.get_children():
			if child is VBoxContainer:
				var distance = test_position.distance_to(child.position)
				if distance < 20:
					overlapping = true
					break
		
		if not overlapping:
			print("Found non-overlapping position after ", attempts, " attempts: ", test_position)
			return test_position
		
		attempts += 1
	
	print("WARNING: Could not find non-overlapping position after ", max_attempts, " attempts")
	
	# Last resort - use predetermined positions
	var safe_positions = [
		Vector2(20, 20),
		Vector2(50, 20),
		Vector2(20, 60),
		Vector2(50, 60),
		Vector2(20, 100),
		Vector2(50, 100)
	]
	
	# Try each safe position
	for safe_pos in safe_positions:
		var is_overlapping = false
		for child in container.get_children():
			if child is VBoxContainer:
				var distance = safe_pos.distance_to(child.position)
				if distance < 20:
					is_overlapping = true
					break
		
		if not is_overlapping:
			#print("Using predetermined safe position: ", safe_pos)
			return safe_pos
	
	# Absolute last resort - top left corner with a small offset
	print("LAST RESORT: Using top-left position")
	return Vector2(5, 5)

func _on_cat_button_pressed(cat_index: int):
	# Check if this cat is already selected
	var is_selected = cat_index in selected_cats

	if is_selected:
		# Deselect the cat
		selected_cats.erase(cat_index)
		cat_sprite_nodes[cat_index].button.modulate = Color(1, 1, 1, 0.4)
	else:
		# Select the cat if we haven't reached max
		if selected_cats.size() < max_cats:
			selected_cats.append(cat_index)
			cat_sprite_nodes[cat_index].button.modulate = Color(1, 1, 1, 1.0)
		else:
			# We've reached max cats, deselect the first one
			var first_selected = selected_cats[0]
			cat_sprite_nodes[first_selected].button.modulate = Color(1, 1, 1, 0.4)
			selected_cats.remove_at(0)

			# Add the new selection
			selected_cats.append(cat_index)
			cat_sprite_nodes[cat_index].button.modulate = Color(1, 1, 1, 1.0)

	continue_button.disabled = selected_cats.size() < 2

func _on_continue_button_pressed():
	if selected_cats.size() < 2:
		print("You must select at least 2 cats.")
		return

	audio1.play()
	await get_tree().create_timer(0.3).timeout
	var merge_scene = load("res://screens/merge.tscn").instantiate()
	merge_scene.selected_cats = selected_cats
	get_tree().root.add_child(merge_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = merge_scene

	# The CatHandler will save automatically when needed

func _on_back_button_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://screens/idle_screen.tscn")
