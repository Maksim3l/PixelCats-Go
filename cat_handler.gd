extends Node

var cat_manager: CatManager
const SAVE_PATH = "res://data/CatManager.tres"

signal cat_stats_updated(cat_data)

func _ready():
	load_cat_manager()

func load_cat_manager():
	var loaded = CatManager.load_cats(SAVE_PATH)
	if loaded == null:
		print("No saved data found. Initializing new CatManager.")
		cat_manager = CatManager.new()
	else:
		cat_manager = loaded
		print("Cat Manager loaded with ", cat_manager.cats.size(), " cats")
		print("Active cat index: ", cat_manager.active_cat_index)

func save_cat_manager():
	if cat_manager:
		cat_manager.save_cats(SAVE_PATH)
	cat_stats_updated.emit(get_active_cat())

func add_new_cat() -> int:
	var new_index = cat_manager.add_new_cat()
	save_cat_manager()
	return new_index

func get_active_cat() -> CatData:
	return cat_manager.get_active_cat()

func switch_cat(index: int) -> CatData:
	var switched_cat = cat_manager.switch_cat(index)
	save_cat_manager()
	return switched_cat

func remove_cat(index: int) -> bool:
	var result = cat_manager.remove_cat(index)
	save_cat_manager()
	return result

func get_all_cats() -> Array[CatData]:
	return cat_manager.cats

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_cat_manager()
		get_tree().quit()
		
# Add these methods to your CatHandler script

# Equip armor on the active cat
func equip_armor_on_active_cat(armor: Item) -> Item:
	var active_cat = get_active_cat()
	var previous_armor = active_cat.equip_armor(armor)
	save_cat_manager()
	cat_stats_updated.emit(active_cat)
	return previous_armor

func equip_armor_on_cat(cat_index: int, armor: Item) -> Item:
	if cat_index >= 0 and cat_index < cat_manager.cats.size():
		var cat = cat_manager.cats[cat_index]
		var previous_armor = cat.equip_armor(armor)
		save_cat_manager()
		cat_stats_updated.emit(cat)
		return previous_armor
	return null

func unequip_armor_from_active_cat(slot: int) -> Item:
	var active_cat = get_active_cat()
	var removed_armor = active_cat.unequip_armor(slot)
	save_cat_manager()
	cat_stats_updated.emit(active_cat)
	return removed_armor

func get_active_cat_equipped_armor() -> Dictionary:
	return get_active_cat().equipped_armor

func active_cat_has_armor_in_slot(slot: int) -> bool:
	return get_active_cat().has_armor_equipped(slot)

func get_active_cat_armor_in_slot(slot: int) -> Item:
	return get_active_cat().get_equipped_armor(slot)

func get_active_cat_armor_defense() -> int:
	return get_active_cat().get_total_armor_defense()

func update_cat_with_equipment(cat: CharacterBody2D, cat_data: CatData) -> void:
	cat_data.apply_to_cat(cat)
	
	if "equipped_armor" in cat:
		cat.equipped_armor = cat_data.equipped_armor
