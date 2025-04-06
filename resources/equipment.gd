class_name Equipment 
extends Resource

@export var name: String = ""
@export var equipment_type: String = "" # weapon, armor, accecs
@export var health_bonus: int = 0
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var icon: Texture2D


func _init(p_name = "", p_type = "", p_health = "", p_attack = 0, p_defense = 0, p_icon = null):
	name = p_name
	equipment_type = p_type
	health_bonus = p_health
	attack_bonus = p_attack
	defense_bonus = p_defense
	icon = p_icon
