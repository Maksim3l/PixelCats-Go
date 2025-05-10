extends Node

var main_music = preload("res://assets/soundFX/8-bit-PixelCatsGoMusic.mp3")
var battle_music = preload("res://assets/soundFX/fighting-music.mp3")

var player_main: AudioStreamPlayer
var player_battle: AudioStreamPlayer

func _ready():
	player_main = AudioStreamPlayer.new()
	player_main.stream = main_music
	player_main.name = "MainMusicPlayer" 
	player_main.bus = "Music" 
	player_main.volume_db=-25
	if main_music is AudioStreamMP3:
		main_music.loop = true
	add_child(player_main) 
	
	player_battle = AudioStreamPlayer.new()
	player_battle.stream = battle_music
	player_battle.name = "BattleMusicPlayer"
	player_battle.bus = "Music"
	player_battle.volume_db=-22
	if battle_music is AudioStreamMP3:
		battle_music.loop = true
	add_child(player_battle)
	
	play_main_music()

func play_main_music():
	
	if player_main.playing:
		return

	if player_battle.playing:
		player_battle.stop()
	
	player_main.play()

func play_battle_music():
	if player_battle.playing:
		return

	if player_main.playing:
		player_main.stop()
	
	player_battle.play(2)
