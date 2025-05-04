extends Control

func _on_play_pressed():
	var active_cat = CatHandler.get_active_cat()
	if (active_cat.energy != 0 && active_cat.energy > 0):
		get_tree().change_scene_to_file("res://screens/battle.tscn")
	else:
		get_tree().change_scene_to_file("res://screens/idle_screen.tscn")

func _on_exit_pressed():
	get_tree().quit()
