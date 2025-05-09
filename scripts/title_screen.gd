extends Control
@onready var audio_player= $VBoxContainer/AudioStreamPlayer2D
@onready var audio_player2= $VBoxContainer/AudioStreamPlayer2D2
func _on_play_pressed():
	audio_player.play()
	
	var active_cat = CatHandler.get_active_cat()
	if (active_cat.energy != 0 && active_cat.energy > 0):
		await get_tree().create_timer(0.25).timeout
		get_tree().change_scene_to_file("res://screens/battle.tscn")
	else:
		get_tree().change_scene_to_file("res://screens/idle_screen.tscn")

func _on_exit_pressed():
	audio_player2.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()
