class_name Equipment 
extends Resource

@export var name: String = ""
@export var health_bonus: int = 0
@export var attack_bonus: int = 0
@export_enum("head", "chest", "legs", "weapon", "shield") var equipment_type: String = "weapon"
@export var defense_bonus: int = 0
@export var icon: Texture2D
@export var level_requirment: int = 1
@export var value: int = 0



func _init(p_name = "", p_type = "", p_health = "", p_attack = 0, p_defense = 0, p_icon = null, p_lvl = 1, p_value = 0):
	name = p_name
	equipment_type = p_type
	health_bonus = p_health
	attack_bonus = p_attack
	defense_bonus = p_defense
	icon = p_icon
	value = p_value
	level_requirment = p_lvl
	
	
func get_description() -> String:
	var desc
	
	if health_bonus != 0: desc += "Health: %+d\n" % health_bonus
	if attack_bonus != 0: desc += "Attack: %+d\n" % attack_bonus
	if defense_bonus != 0: desc += "Defense: %+d\n" % defense_bonus
	if level_requirment != 0: desc += "Level: %d\n"	% level_requirment
	if value != 0: desc += "Value: %d\n" % value

	return desc
