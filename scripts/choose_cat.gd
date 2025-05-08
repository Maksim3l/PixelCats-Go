extends Node2D

@onready var continue_button: Button = $ContinueButton
@onready var back_button: Button = $BackButton
@onready var cats_list: VBoxContainer = $CatList2

# Track selected cats
var selected_cats = []
var max_cats = 2

# Font file
var font_file

func _ready():
	# Load font file (ttf)
	font_file = preload("res://resources/pixel_sans.ttf")

	# Apply font and small size to buttons
	continue_button.add_theme_font_override("font", font_file)
	continue_button.add_theme_font_size_override("font_size", 5)
	
	back_button.add_theme_font_override("font", font_file)
	back_button.add_theme_font_size_override("font_size", 5)

	populate_cats_list()
	continue_button.connect("pressed", Callable(self, "_on_continue_button_pressed"))
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	continue_button.disabled = true

func populate_cats_list():
	# Clear existing list items
	for child in cats_list.get_children():
		child.queue_free()
	
	# Get all cats from the CatHandler singleton
	var all_cats = CatHandler.get_all_cats()
	
	for i in range(all_cats.size()):
		var cat = all_cats[i]
		var checkbox = CheckButton.new()
		checkbox.text = cat.cat_name
		
		# Apply font and small size to checkboxes
		checkbox.add_theme_font_override("font", font_file)
		checkbox.add_theme_font_size_override("font_size", 4)
		
		checkbox.connect("toggled", Callable(self, "_on_cat_checkbox_toggled").bind(i))
		cats_list.add_child(checkbox)

func _on_cat_checkbox_toggled(pressed: bool, cat_index: int):
	if pressed:
		if cat_index not in selected_cats:
			selected_cats.append(cat_index)
	else:
		selected_cats.erase(cat_index)

	# Enforce max selection
	if selected_cats.size() > max_cats:
		var last_index = selected_cats.pop_back()
		for child in cats_list.get_children():
			if child is CheckButton and child.text == CatHandler.get_all_cats()[last_index].cat_name:
				child.button_pressed = false
				break

	continue_button.disabled = selected_cats.size() < 2

func _on_continue_button_pressed():
	if selected_cats.size() < 2:
		print("You must select at least 2 cats.")
		return

	var merge_scene = load("res://screens/merge.tscn").instantiate()
	merge_scene.selected_cats = selected_cats
	get_tree().root.add_child(merge_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = merge_scene
	
	# The CatHandler will save automatically when needed

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://screens/idle_screen.tscn")
