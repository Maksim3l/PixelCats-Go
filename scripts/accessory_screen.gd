# AccessoryScreen.gd
extends Node2D

# Reference na prikaznega playerja (celoten Player.tscn instanciran v tej sceni)
@onready var displayed_player_node: CharacterBody2D = $Organizer/CenterBG/player 

# Reference na gumbe - PRILAGODI POTI, ČE SO DRUGAČNE!
# Predpostavljam, da so vsi gumbi otroci $Organizer/UICenter/AccessoryPanel
# Če jih imaš v ločenih kontejnerjih (npr. en za glavo, en za telo), prilagodi.
@onready var head_buttons: Array[Button] = [
	$Organizer/UICenter/AccessoryPanel/crown,   # Head Item 1 (prvi gumb v panelu)
	$Organizer/UICenter/AccessoryPanel/ninja,  # Head Item 2 (drugi gumb v panelu)
	$Organizer/UICenter/AccessoryPanel/glasses,  # Head Item 3 (...)
	$Organizer/UICenter/AccessoryPanel/mask   # Head Item 4
]
@onready var body_buttons: Array[Button] = [
	$Organizer/UICenter/AccessoryPanel/tie,  # Body Item 1 (peti gumb v panelu)
	$Organizer/UICenter/AccessoryPanel/belt,  # Body Item 2 (...)
	$Organizer/UICenter/AccessoryPanel/robot_arm,  # Body Item 3
	$Organizer/UICenter/AccessoryPanel/swim   # Body Item 4
]

@onready var audio_player_ui_sfx = $Organizer/Center/AudioStreamPlayer2D2 
@onready var gold_label = $"Organizer/UITop/ProfileUI/Gold/value"

@onready var crown_lock = $"Organizer/UICenterBG/AccessoryPanel/crownLock"
@onready var ninja_lock = $"Organizer/UICenterBG/AccessoryPanel/ninjaLock"
@onready var glasses_lock = $"Organizer/UICenterBG/AccessoryPanel/glassesLock"
@onready var mask_lock = $"Organizer/UICenterBG/AccessoryPanel/maskLock"
@onready var swim_lock = $"Organizer/UICenterBG/AccessoryPanel/swimLock"
@onready var robot_lock = $"Organizer/UICenterBG/AccessoryPanel/robot_armLock"
@onready var belt_lock = $"Organizer/UICenterBG/AccessoryPanel/beltLock"
@onready var tie_lock = $"Organizer/UICenterBG/AccessoryPanel/tieLock"

var accessory_locks = {
	"crown": crown_lock,
	"ninja": ninja_lock,
	"glasses": glasses_lock,
	"mask": mask_lock,
	"swim": swim_lock,
	"robot_arm": robot_lock,
	"belt": belt_lock,
	"tie": tie_lock
}

# Hardkodirani itemi (poti do SpriteFrames) - ZAMENJAJ S SVOJIMI POTMI!
var head_items_sf_paths = [
	"res://accessories/head/head_item_1/crown_spritesheet.tres", # Primer za krono
	"res://accessories/head/head_item_2/ninja_spritesheet.tres",    
	"res://accessories/head/head_item_3/sun.tres",
	"res://accessories/head/head_item_4/mask.tres"
]
var body_items_sf_paths = [
	"res://accessories/body/body_item_4/tie.tres",
	"res://accessories/body/body_item_3/belt.tres",
	"res://accessories/body/body_item_2/robot.tres",
	"res://accessories/body/body_item_1/swim.tres"
]

var current_preview_cat_data: CatData 

func _ready():
	MusicManager.play_main_music()
	gold_label.text = str(GlobalDataHandler.global_data.gold)

	var real_active_cat_data = CatHandler.get_active_cat()
	if real_active_cat_data:
		current_preview_cat_data = real_active_cat_data.duplicate(true) # Uporabi deep copy za urejanje
		
		# Nanesi podatke na prikazni Player node
		apply_preview_data_to_displayed_player()
		
		if displayed_player_node.has_method("play_animation"):
			displayed_player_node.play_animation("idle")
		elif displayed_player_node.has_node("Catimation"): # Fallback za animacijo
			var catimation_on_preview = displayed_player_node.get_node("Catimation") as AnimatedSprite2D
			if catimation_on_preview and catimation_on_preview.sprite_frames:
				catimation_on_preview.play("idle")
		if displayed_player_node.has_node("PlayerHealthBar"):
			var health_bar = displayed_player_node.get_node("PlayerHealthBar")
			health_bar.visible = false		
	else:
		printerr("AccessoryScreen: Could not get active cat data! Creating empty preview data.")
		current_preview_cat_data = CatData.new() # Ustvari prazen preview data, da se izogneš kasnejšim napakam

	# Poveži signale gumbov in nastavi začetne ikone
	for i in range(head_buttons.size()):
		var button = head_buttons[i]
		if button is Button: # Preveri, če je node res gumb
			button.pressed.connect(Callable(self, "_on_head_item_button_pressed").bind(i))
			update_button_state(button, "head", i)
		else:
			printerr("Head button at index " + str(i) + " is not a Button or not found at expected path.")


	for i in range(body_buttons.size()):
		var button = body_buttons[i]
		if button is Button:
			button.pressed.connect(Callable(self, "_on_body_item_button_pressed").bind(i))
			update_button_state(button, "body", i)
		else:
			printerr("Body button at index " + str(i) + " is not a Button or not found at expected path.")

# Nova funkcija za nanos podatkov na prikazni model
func apply_preview_data_to_displayed_player():
	if not current_preview_cat_data or not displayed_player_node:
		printerr("Cannot apply preview data: preview data or displayed player node is null.")
		return

	# Predpostavljamo, da displayed_player_node ima Player.gd skripto
	if displayed_player_node.has_method("apply_cat_data"): # Če si ustvaril to metodo v Player.gd
		displayed_player_node.apply_cat_data(current_preview_cat_data)
	else: # Fallback, če Player.gd nima apply_cat_data, ampak ima set_equipment
		# Najprej nanesi osnovne podatke mačke (če je potrebno za prikaz)
		if displayed_player_node.has_node("Catimation") and current_preview_cat_data.cat_sprite != "":
			var catimation_preview = displayed_player_node.get_node("Catimation") as AnimatedSprite2D
			var cat_sf = load(current_preview_cat_data.cat_sprite) # cat_sprite naj bo pot do SpriteFrames
			if cat_sf is SpriteFrames:
				catimation_preview.sprite_frames = cat_sf
			else:
				printerr("Failed to load cat SpriteFrames for preview: " + current_preview_cat_data.cat_sprite)
		
		# Nato opremo
		if displayed_player_node.has_method("set_equipment"):
			displayed_player_node.set_equipment("head", current_preview_cat_data.equipped_head_sf_path)
			displayed_player_node.set_equipment("body", current_preview_cat_data.equipped_body_sf_path)
		else:
			printerr("Displayed player node does not have set_equipment method.")


# Funkcija za posodobitev STANJA gumba (brez ikon)
func update_button_state(button_node: Button, item_type: String, item_index: int):
	if not current_preview_cat_data or not button_node:
		return

	var item_sf_path = ""
	var currently_equipped = ""

	if item_type == "head":
		item_sf_path = head_items_sf_paths[item_index]
		currently_equipped = current_preview_cat_data.equipped_head_sf_path
	elif item_type == "body":
		item_sf_path = body_items_sf_paths[item_index]
		currently_equipped = current_preview_cat_data.equipped_body_sf_path
	else:
		return

	var accessory_name = button_node.name
	var lock_node = button_node.get_parent().get_node_or_null(accessory_name + "Lock")

	if not GlobalDataHandler.has_accessory(accessory_name):
		button_node.disabled = true
		button_node.text = ""
		if lock_node:
			lock_node.visible = true
		return

	button_node.disabled = false
	if lock_node:
		lock_node.visible = false

	if item_sf_path == currently_equipped:
		button_node.text = "X"
	else:
		button_node.text = ""	
		
		
# Funkcija, ki se sproži ob kliku na gumb za GLAVO
func _on_head_item_button_pressed(item_index: int):
	if not current_preview_cat_data or not displayed_player_node: return
	if not displayed_player_node.has_method("set_equipment"):
		printerr("Displayed player node missing 'set_equipment' method.")
		return

	var selected_sf_path = head_items_sf_paths[item_index]
	var new_head_path = ""

	if current_preview_cat_data.equipped_head_sf_path == selected_sf_path:
		new_head_path = "" # Odstrani
	else:
		new_head_path = selected_sf_path # Opremi
	
	# Samo posodobi podatke v preview_cat_data
	current_preview_cat_data.equipped_head_sf_path = new_head_path
	# In nato kliči metodo, ki osveži celoten prikaz igralca na podlagi teh podatkov
	apply_preview_data_to_displayed_player() 
	
	# Po apply_preview_data_to_displayed_player, ki bo poklical set_equipment,
	# bo displayed_player_node že moral imeti pravilno animacijo na opremi.
	# Za vsak slučaj lahko še enkrat zagotovimo, da je v idle.
	if displayed_player_node.has_method("play_animation"):
		displayed_player_node.play_animation("idle") # Zagotovi idle stanje za prikaz
	
	for i in range(head_buttons.size()):
		if head_buttons[i] is Button: update_button_state(head_buttons[i], "head", i)

func _on_body_item_button_pressed(item_index: int):
	if not current_preview_cat_data or not displayed_player_node: return
	if not displayed_player_node.has_method("set_equipment"):
		printerr("Displayed player node missing 'set_equipment' method.")
		return
		
	var selected_sf_path = body_items_sf_paths[item_index]
	var new_body_path = ""

	if current_preview_cat_data.equipped_body_sf_path == selected_sf_path:
		new_body_path = ""
	else:
		new_body_path = selected_sf_path
	
	current_preview_cat_data.equipped_body_sf_path = new_body_path
	apply_preview_data_to_displayed_player()
	
	if displayed_player_node.has_method("play_animation"):
		displayed_player_node.play_animation("idle") # Zagotovi idle stanje za prikaz
		
	for i in range(body_buttons.size()):
		if body_buttons[i] is Button: update_button_state(body_buttons[i], "body", i)

# Ko igralec zapusti zaslon
func _on_back_pressed():
	if audio_player_ui_sfx: audio_player_ui_sfx.play()
	await get_tree().create_timer(0.25).timeout
	
	if current_preview_cat_data: 
		var real_active_cat_data = CatHandler.get_active_cat()
		if real_active_cat_data:
			real_active_cat_data.equipped_head_sf_path = current_preview_cat_data.equipped_head_sf_path
			real_active_cat_data.equipped_body_sf_path = current_preview_cat_data.equipped_body_sf_path
		CatHandler.save_cat_manager()
	
	var previous_scene_path = GlobalDataHandler.global_data.coming_from_last
	var target_scene_path = "res://screens/idle_screen.tscn" 
	
	if previous_scene_path == "Battle Arena":
		target_scene_path = "res://screens/battle.tscn"
	
	_load_scene(target_scene_path)

func _load_scene(scene_path: String):
	var new_scene_resource = load(scene_path)
	if new_scene_resource:
		var new_scene_instance = new_scene_resource.instantiate()
		var current_scene_node = get_tree().current_scene
		
		get_tree().root.add_child(new_scene_instance)
		get_tree().current_scene = new_scene_instance
		
		if is_instance_valid(current_scene_node): # Preveri, preden kličeš queue_free
			current_scene_node.queue_free()
	else:
		printerr("Failed to load scene: " + scene_path)
