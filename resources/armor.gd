# Armor.gd
extends Node

# Pre-defined armor categories
enum ArmorTypes {CHEST, GLOVES, BOOTS, HELMET}

var armors = {
	# CHEST ARMOR
	"leather_chest": {
		"id": "leather_chest",
		"name": "Leather Chest",
		#"texture": "res://textures/armor/leather_chest.png",
		"type": Item.ItemType.ARMOR,
		"slot": Item.ItemSlot.TORSO,
		"attack_bonus": 0,
		"defense_bonus": 5,
		"health_bonus": 10,
		"energy_bonus": 0,
		"gold_value": 60,
	},
	"mage_robe": {
		"id": "mage_robe",
		"name": "Mage Robe",
		#"texture": "res://textures/armor/mage_robe.png",
		"type": Item.ItemType.ARMOR,
		"slot": Item.ItemSlot.TORSO,
		"attack_bonus": 5,
		"defense_bonus": 8,
		"health_bonus": 15,
		"energy_bonus": 5,
		"gold_value": 380,
	},
   
	
	# GLOVES
	"leather_gloves": {
		"id": "leather_gloves",
		"name": "Leather Gloves",
		#"texture": "res://textures/armor/leather_gloves.png",
		"type": Item.ItemType.ARMOR,
		"slot": Item.ItemSlot.ARM_BACK,
		"attack_bonus": 1,
		"defense_bonus": 2,
		"health_bonus": 0,
		"energy_bonus": 0,
		"gold_value": 30,
	},   
	
	# BOOTS
	"leather_boots": {
		"id": "leather_boots",
		"name": "Leather Boots",
		"texture": "res://textures/armor/leather_boots.png",
		"type": Item.ItemType.ARMOR,
		"slot": Item.ItemSlot.LEG_FRONT,
		"attack_bonus": 0,
		"defense_bonus": 2,
		"health_bonus": 5,
		"energy_bonus": 1,
		"gold_value": 35,
	},    
	
	# HELMETS (HEAD SLOT)
	"leather_cap": {
		"id": "leather_cap",
		"name": "Leather Cap",
		#"texture": "res://textures/armor/leather_cap.png",
		"type": Item.ItemType.ARMOR,
		"slot": Item.ItemSlot.HEAD,
		"attack_bonus": 0,
		"defense_bonus": 3,
		"health_bonus": 5,
		"energy_bonus": 0,
		"gold_value": 40,
	},
}

# an armor item by its ID
func get_armor(armor_id: String) -> Item:
	if not armor_id in armors:
		print("Armor ID not found: ", armor_id)
		return null
		
	return Item.from_dict(armors[armor_id])


func get_armor_by_slot(slot: int) -> Array:
	var result = []
	
	for armor_id in armors:
		var armor_data = armors[armor_id]
		if armor_data.slot == slot:
			result.append(get_armor(armor_id))
			
	return result
	
# Get all available armor items
func get_all_armor() -> Array:
	var result = []
	
	for armor_id in armors:
		result.append(get_armor(armor_id))
		
	return result
	
func get_collected_armor() -> Array:
	var result = []
	
	for armor_id in GlobalDataHandler.global_data.collected_armor_ids:
		result.append(get_armor(armor_id))
		
	return result
