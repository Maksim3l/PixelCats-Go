extends CanvasLayer

@onready var mbtn = $UIBottom/BottomUI/Merge
@onready var fbtn = $UIBottom/BottomUI/Feed
@onready var ebtn = $UIBottom/BottomUI/Equipment
@onready var abtn = $UIBottom/BottomUI/Accessories
@onready var pbtn = $UIBottom/BottomUI/Pets

var custom_font = preload("res://resources/pixel_sans.ttf")



# Here to be copy and paisted for convenience
# get_tree().change_scene_to_file("res://screens/battle.tscn")

func _on_merge_pressed():
	get_tree().change_scene_to_file("res://screens/merge.tscn")


func _on_feed_pressed():
	pass # Replace with function body.


func _on_equipment_pressed():
	pass # Replace with function body.


func _on_accessories_pressed():
	pass # Replace with function body.


func _on_pets_pressed():
	pass # Replace with function body.


func _on_battle_pressed():
	get_tree().change_scene_to_file("res://screens/battle.tscn")
