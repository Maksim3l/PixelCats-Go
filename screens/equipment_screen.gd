extends Node2D

@onready var head_slot = $Organizer/UICenter/LeftCol/Head
@onready var torso_slot = $Organizer/UICenter/LeftCol/Torso
@onready var arm_slot = $Organizer/UICenter/LeftCol/Arms
@onready var leg_slot = $Organizer/UICenter/LeftCol/Legs
@onready var cat_stats_display = $Organizer/UICenter/RightCol/Info
@onready var inventory_grid = $Organizer/PanelContainer/VScrollBar/InventoryGrid

@export var player_character: Node2D

func _ready():
	if CatHandler:
		CatHandler.connect("cat_stats_updated", Callable(self,"_on_cat_stats_updated"))
	
	if player_character.has_method("idle"):
		player_character.idle()
	
	player_character.position.y = 50
	player_character.position.x = 20
	
	refresh_equipment_ui()
	
	head_slot.connect("pressed", _on_head_slot_pressed)
	torso_slot.connect("pressed", _on_torso_slot_pressed)
	arm_slot.connect("pressed", _on_arm_slot_pressed)
	leg_slot.connect("pressed", _on_leg_slot_pressed)

func refresh_equipment_ui():
	update_equipment_slots()
	update_stats_display()
	update_inventory_display()

func update_equipment_slots():
	var active_cat = CatHandler.get_active_cat()
	
	update_slot_visual(head_slot, active_cat.get_equipped_armor(Item.ItemSlot.HEAD))
	update_slot_visual(torso_slot, active_cat.get_equipped_armor(Item.ItemSlot.TORSO))
	update_slot_visual(arm_slot, active_cat.get_equipped_armor(Item.ItemSlot.ARM_BACK))
	update_slot_visual(leg_slot, active_cat.get_equipped_armor(Item.ItemSlot.LEG_FRONT))

func update_slot_visual(slot_button: TextureButton, armor_item: Item):
	if armor_item and "texture" in armor_item:
		var texture = load(armor_item.texture) if typeof(armor_item.texture) == TYPE_STRING else armor_item.texture
		slot_button.texture_normal = texture
		
		var tooltip = "%s\nDEF: +%d | ATK: +%d\nHP: +%d | Energy: +%d" % [
			armor_item.name,
			armor_item.defense_bonus,
			armor_item.attack_bonus,
			armor_item.health_bonus,
			armor_item.energy_bonus
		]
		slot_button.tooltip_text = tooltip
	elif armor_item:
		if armor_item.item_slot == Item.ItemSlot.HEAD:
			slot_button.texture_normal = load("res://assets/tmp_head.png")  
			slot_button.tooltip_text = armor_item.name
		elif armor_item.item_slot == Item.ItemSlot.TORSO:
			slot_button.texture_normal = load("res://assets/tmp_torso.png")  
			slot_button.tooltip_text = armor_item.name
		elif armor_item.item_slot == Item.ItemSlot.ARM_BACK:
			slot_button.texture_normal = load("res://assets/tmp_arm.png")  
			slot_button.tooltip_text = armor_item.name
		elif armor_item.item_slot == Item.ItemSlot.LEG_FRONT:
			slot_button.texture_normal = load("res://assets/tmp_legs.png")  
			slot_button.tooltip_text = armor_item.name
		else:
			slot_button.texture_normal = load("res://assets/tmp_empty.png")  
			slot_button.tooltip_text = "Empty Slot"

func update_stats_display():
	var active_cat = CatHandler.get_active_cat()
	
	var base_attack = active_cat.attack - active_cat.get_total_armor_attack()
	var base_defense = active_cat.defense - active_cat.get_total_armor_defense()
	var base_health = active_cat.max_health - active_cat.get_total_armor_health()
	var base_energy = active_cat.max_energy - active_cat.get_total_armor_energy()
	
	cat_stats_display.text = """
	Cat: %s (Level %d)
	Health: %d/%d (+%d from equipment)
	Attack: %d (+%d from equipment)
	Defense: %d (+%d from equipment)
	Energy: %d/%d (+%d from equipment)
	""" % [
		active_cat.cat_name,
		active_cat.level,
		active_cat.current_health,
		active_cat.max_health,
		active_cat.get_total_armor_health(),
		base_attack,
		active_cat.get_total_armor_attack(),
		base_defense,
		active_cat.get_total_armor_defense(),
		active_cat.energy,
		active_cat.max_energy,
		active_cat.get_total_armor_energy()
	]

# Update the inventory display with available armor
func update_inventory_display():
	# Clear existing items
	for child in inventory_grid.get_children():
		child.queue_free()
		
	#var all_armor = Armor.get_collected_armor()
	
	# Get all armor items
	var all_armor = Armor.get_all_armor()
	
	for armor in all_armor:
		var item_button = TextureButton.new()
		var texture = null

		if texture == null:
			match armor.item_slot:
				Item.ItemSlot.HEAD:
					texture = load("res://assets/tmp_head.png")
				Item.ItemSlot.TORSO:
					texture = load("res://assets/tmp_torso.png")
				Item.ItemSlot.ARM_BACK:
					texture = load("res://assets/tmp_arm.png")
				Item.ItemSlot.LEG_FRONT:
					texture = load("res://assets/tmp_legs.png")
				_:
					texture = load("res://assets/tmp_empty.png")
		item_button.texture_normal = texture
		
		item_button.custom_minimum_size = Vector2(16, 16)
		item_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		item_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		
		# Set tooltip with item info
		item_button.tooltip_text = "%s\nDEF: +%d | ATK: +%d\nHP: +%d | Energy: +%d" % [
			armor.name,
			armor.defense_bonus,
			armor.attack_bonus,
			armor.health_bonus,
			armor.energy_bonus
		]
		
		# Store the armor data with the button
		item_button.set_meta("armor_id", armor.id)
		
		# Connect signal
		item_button.connect("pressed", _on_armor_item_selected.bind(armor))
		
		# Add to grid
		inventory_grid.add_child(item_button)

# Equipment slot button handlers
func _on_head_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.HEAD)

func _on_torso_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.TORSO)

func _on_arm_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.ARM_BACK)

func _on_leg_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.LEG_FRONT)

# Handle equipment slot interaction
func handle_equipment_slot(slot: int):
	var active_cat = CatHandler.get_active_cat()
	
	# If cat has armor in this slot, unequip it
	if active_cat.has_armor_equipped(slot):
		var unequipped_item = CatHandler.unequip_armor_from_active_cat(slot)
		if unequipped_item:
			print("Unequipped: ", unequipped_item.name)
			CatHandler.save_cat_manager()
			refresh_equipment_ui()
	else:
		# Show armor selection for this slot
		show_armor_selection_for_slot(slot)

# Show UI for selecting armor for a specific slot
func show_armor_selection_for_slot(slot: int):
	# This is a placeholder - you would implement a UI to filter and show
	# only armor that fits the selected slot
	var slot_armor = Armor.get_armor_by_slot(slot)
	
	# For now, just print available armor
	print("Available armor for slot ", slot, ":")
	for armor in slot_armor:
		print("- ", armor.name)
	
	# In a real implementation, you'd show these items in a popup or panel

# When player selects armor from inventory
func _on_armor_item_selected(armor: Item):
	# Check if armor is valid for active cat
	var active_cat = CatHandler.get_active_cat()
	
	# Equip the armor
	var previous_armor = CatHandler.equip_armor_on_active_cat(armor)
	
	if previous_armor:
		print("Replaced: ", previous_armor.name, " with ", armor.name)
		# Handle the replaced item (return to inventory)
	else:
		print("Equipped: ", armor.name)
	
	# Refresh UI
	refresh_equipment_ui()

# When cat stats are updated externally
func _on_cat_stats_updated(cat_data: CatData):
	if cat_data == CatHandler.get_active_cat():
		refresh_equipment_ui()
