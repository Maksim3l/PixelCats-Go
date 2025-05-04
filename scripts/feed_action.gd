extends CanvasLayer

@onready var mbtn = $UIBottom/Merge
@onready var fbtn = $UIBottom/Feed
@onready var ebtn = $UIBottom/Equipment
@onready var abtn = $UIBottom/Accessories
@onready var pbtn = $UIBottom/Pets

var custom_font = preload("res://resources/pixel_sans.ttf")

func _ready():
	mbtn.add_theme_font_override("font", custom_font) 
	fbtn.add_theme_font_override("font", custom_font) 
	ebtn.add_theme_font_override("font", custom_font) 
	abtn.add_theme_font_override("font", custom_font) 
	pbtn.add_theme_font_override("font", custom_font) 

# Here to be copy and paisted for convenience
# get_tree().change_scene_to_file("res://screens/battle.tscn")

func _on_bisquit_pressed():
	get_tree().change_scene_to_file("res://screens/merge.tscn")


func _on_catnip_pressed():
	pass # Replace with function body.


func _on_soft_pressed():
	pass # Replace with function body.


func _on_packet_pressed():
	pass # Replace with function body.


func _on_fish_pressed():
	pass # Replace with function body.


func _on_back_pressed():
	get_tree().change_scene_to_file("res://screens/battle.tscn")
