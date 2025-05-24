extends Node
enum WeaponTypes { SWORD, BOW, WAND }

var weapons = {
	"basic_sword": {
		"id": "basic_sword",
		"name": "Basic Sword",
		"texture": "res://characters/main/basic_sword.png",
		"item_type": Item.ItemType.WEAPON,
		"type": WeaponTypes.SWORD,
		"slot": Item.ItemSlot.ARM_FRONT,
		"attack_bonus": 5,
		"defense_bonus": 1,
		"health_bonus": 0,
		"energy_bonus": 0,
		"gold_value": 5,
	},
	"hunting_bow": {
		"id": "hunting_bow",
		"name": "Hunting Bow",
		"texture": "res://characters/main/basic_bow.png",
		"item_type": Item.ItemType.WEAPON,
		"type": WeaponTypes.BOW,
		"slot": Item.ItemSlot.ARM_FRONT,
		"attack_bonus": 7,
		"defense_bonus": 0,
		"health_bonus": 0,
		"energy_bonus": 1,
		"gold_value": 10,
	},
	"basic_wand": {
		"id": "basic_wand",
		"name": "Basic Wand",
		"texture": "res://characters/main/basic_wand.png",
		"item_type": Item.ItemType.WEAPON,
		"type": WeaponTypes.WAND,
		"slot": Item.ItemSlot.ARM_FRONT,
		"attack_bonus": 6,
		"defense_bonus": 0,
		"health_bonus": 3,
		"energy_bonus": 1,
		"gold_value": 12,
	}
}

func get_weapon(weapon_id: String) -> Item:
	if not weapons.has(weapon_id):
		print("Weapon ID not found: ", weapon_id)
		return null
	return Item.from_dict(weapons[weapon_id])

func get_weapons_by_type(type: int) -> Array:
	var result = []
	for weapon_id in weapons:
		var weapon_data = weapons[weapon_id]
		if weapon_data["type"] == type:
			result.append(get_weapon(weapon_id))
	return result

func get_all_weapons() -> Array:
	var result = []
	for weapon_id in weapons:
		result.append(get_weapon(weapon_id))
	return result
