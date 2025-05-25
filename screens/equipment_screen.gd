extends Node2D

@onready var head_slot = $Organizer/UICenter/LeftCol/Head
@onready var torso_slot = $Organizer/UICenter/LeftCol/Torso
@onready var arm_slot = $Organizer/UICenter/LeftCol/Arms
@onready var leg_slot = $Organizer/UICenter/LeftCol/Legs
@onready var item_slot = $Organizer/UICenter/LeftCol/Item
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
	item_slot.connect("pressed", _on_weapon_slot_pressed) 

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
	update_weapon_slot_visual(item_slot, active_cat.get_equipped_weapon())

func update_slot_visual(slot_button: TextureButton, armor_item: Item):
	if armor_item:
		if armor_item and "texture" in armor_item:
			var texture = load(armor_item.texture) if typeof(armor_item.texture) == TYPE_STRING else armor_item.texture
			slot_button.texture_normal = texture
			
		else:
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
			
		var tooltip = "%s\nDEF: +%d | ATK: +%d\nHP: +%d | Energy: +%d" % [
		armor_item.name,
		armor_item.defense_bonus,
		armor_item.attack_bonus,
		armor_item.health_bonus,
		armor_item.energy_bonus
		]
		slot_button.tooltip_text = tooltip
	
	else:
		slot_button.texture_normal = load("res://assets/tmp_empty.png")
		slot_button.tooltip_text = "Empty Slot"


func update_weapon_slot_visual(slot_button: TextureButton, weapon_item: Item):
	if weapon_item and "texture" in weapon_item:
		var texture = load(weapon_item.texture) if typeof(weapon_item.texture) == TYPE_STRING else weapon_item.texture
		slot_button.texture_normal = texture
		
		var tooltip = "%s\nATK: +%d | DEF: +%d\nHP: +%d | Energy: +%d" % [
			weapon_item.name,
			weapon_item.attack_bonus,
			weapon_item.defense_bonus,
			weapon_item.health_bonus,
			weapon_item.energy_bonus
		]
		slot_button.tooltip_text = tooltip
	elif weapon_item:
		slot_button.texture_normal = load("res://assets/tmp_weapon.png")
		slot_button.tooltip_text = "%s\nATK: +%d | DEF: +%d\nHP: +%d | Energy: +%d" % [
			weapon_item.name,
			weapon_item.attack_bonus,
			weapon_item.defense_bonus,
			weapon_item.health_bonus,
			weapon_item.energy_bonus
		]
	else:
		slot_button.texture_normal = load("res://assets/tmp_empty.png")
		slot_button.tooltip_text = "Empty Weapon Slot"

func update_stats_display():
	var active_cat = CatHandler.get_active_cat()
	
	var base_attack = active_cat.attack - active_cat.get_total_armor_attack() - active_cat.get_weapon_attack()
	var base_defense = active_cat.defense - active_cat.get_total_armor_defense() - active_cat.get_weapon_defense()
	var base_health = active_cat.max_health - active_cat.get_total_armor_health() - active_cat.get_weapon_health()
	var base_energy = active_cat.max_energy - active_cat.get_total_armor_energy() - active_cat.get_weapon_energy()
	
	var equipment_attack = active_cat.get_total_armor_attack() + active_cat.get_weapon_attack()
	var equipment_defense = active_cat.get_total_armor_defense() + active_cat.get_weapon_defense()
	var equipment_health = active_cat.get_total_armor_health() + active_cat.get_weapon_health()
	var equipment_energy = active_cat.get_total_armor_energy() + active_cat.get_weapon_energy()
	
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

func update_inventory_display():
	for child in inventory_grid.get_children():
		child.queue_free()
	
	var all_armor = Armor.get_all_armor()
	
	for armor in all_armor:
		add_item_to_inventory(armor, true)

	var all_weapons = Weapons.get_all_weapons()
	
	for weapon in all_weapons:
		add_item_to_inventory(weapon, false)

func add_item_to_inventory(item: Item, is_armor: bool):
	var item_button = TextureButton.new()
	var texture = null

	if "texture" in item and item.texture != "":
		texture = load(item.texture) if typeof(item.texture) == TYPE_STRING else item.texture

	if texture == null:
		if is_armor:
			match item.item_slot:
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
		else:
			texture = load("res://assets/tmp_weapon.png")
	
	item_button.texture_normal = texture
	
	item_button.custom_minimum_size = Vector2(16, 16)
	item_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	item_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	item_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	item_button.tooltip_text = "%s\nATK: +%d | DEF: +%d\nHP: +%d | Energy: +%d" % [
		item.name,
		item.attack_bonus,
		item.defense_bonus,
		item.health_bonus,
		item.energy_bonus
	]
	
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(4)
	style_box.bg_color = Color(0, 0, 0, 0.6)
	
	var custom_theme = Theme.new()
	custom_theme.set_stylebox("panel", "TooltipPanel", style_box)
	custom_theme.set_font_size("font_size", "TooltipLabel", 4) 
	item_button.theme = custom_theme

	if is_armor:
		item_button.set_meta("armor_id", item.id)
		item_button.connect("pressed", _on_armor_item_selected.bind(item))
	else:
		item_button.set_meta("weapon_id", item.id)
		item_button.connect("pressed", _on_weapon_item_selected.bind(item))
	
	inventory_grid.add_child(item_button)

func _on_head_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.HEAD)

func _on_torso_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.TORSO)

func _on_arm_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.ARM_BACK)

func _on_leg_slot_pressed():
	handle_equipment_slot(Item.ItemSlot.LEG_FRONT)
	
func _on_weapon_slot_pressed():
	handle_weapon_slot()

func handle_equipment_slot(slot: int):
	var active_cat = CatHandler.get_active_cat()
	
	if active_cat.has_armor_equipped(slot):
		var unequipped_item = CatHandler.unequip_armor_from_active_cat(slot)
		if unequipped_item:
			print("Unequipped: ", unequipped_item.name)
			CatHandler.save_cat_manager()
			refresh_equipment_ui()
	else:
		show_armor_selection_for_slot(slot)

func handle_weapon_slot():
	var active_cat = CatHandler.get_active_cat()

	if active_cat.has_weapon_equipped():
		var unequipped_weapon = CatHandler.unequip_weapon_from_active_cat()
		if unequipped_weapon:
			print("Unequipped weapon: ", unequipped_weapon.name)
			CatHandler.save_cat_manager()
			refresh_equipment_ui()
	else:
		show_weapon_selection()

func show_armor_selection_for_slot(slot: int):
	var slot_armor = Armor.get_armor_by_slot(slot)
	print("Available armor for slot ", slot, ":")
	for armor in slot_armor:
		print("- ", armor.name)

func show_weapon_selection():
	var all_weapons = Weapons.get_all_weapons()
	print("Available weapons:")
	for weapon in all_weapons:
		print("- ", weapon.name)

func _on_armor_item_selected(armor: Item):
	var active_cat = CatHandler.get_active_cat()
	var previous_armor = CatHandler.equip_armor_on_active_cat(armor)
	
	if previous_armor:
		print("Replaced: ", previous_armor.name, " with ", armor.name)
	else:
		print("Equipped: ", armor.name)

	CatHandler.save_cat_manager()
	refresh_equipment_ui()

func _on_weapon_item_selected(weapon: Item):
	var active_cat = CatHandler.get_active_cat()
	var previous_weapon = active_cat.equip_weapon(weapon)
	if previous_weapon:
		print("Replaced weapon: ", previous_weapon.name, " with ", weapon.name)
	else:
		print("Equipped weapon: ", weapon.name)
	
	CatHandler.save_cat_manager()
	refresh_equipment_ui()

func _on_cat_stats_updated(cat_data: CatData):
	if cat_data == CatHandler.get_active_cat():
		refresh_equipment_ui()
