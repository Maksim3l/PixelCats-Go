extends Control

func _on_play_pressed():
	get_tree().change_scene_to_file("res://screens/battle.tscn")

func _on_exit_pressed():
	get_tree().quit()
