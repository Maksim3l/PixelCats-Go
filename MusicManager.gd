extends Node

var main_music = preload("res://assets/soundFX/8-bit-PixelCatsGoMusic.mp3")
var battle_music = preload("res://assets/soundFX/fighting-music.mp3")

var player_main: AudioStreamPlayer
var player_battle: AudioStreamPlayer

# Trenutna glasnost (0.0 - 1.0)
var current_volume := 1.0

func _ready():
	# Ustvari in nastavi predvajalnik za main
	player_main = AudioStreamPlayer.new()
	player_main.stream = main_music
	player_main.name = "MainMusicPlayer"
	player_main.bus = "Music"
	add_child(player_main)
	
	if main_music is AudioStreamMP3:
		main_music.loop = true

	# Ustvari in nastavi predvajalnik za battle
	player_battle = AudioStreamPlayer.new()
	player_battle.stream = battle_music
	player_battle.name = "BattleMusicPlayer"
	player_battle.bus = "Music"
	add_child(player_battle)

	if battle_music is AudioStreamMP3:
		battle_music.loop = true

	# Nastavi začetno glasnost
	set_music_volume(current_volume)

	play_main_music()

func play_main_music():
	if player_main.playing:
		return
	player_battle.stop()
	player_main.play()

func play_battle_music():
	if player_battle.playing:
		return
	player_main.stop()
	player_battle.play(2)

func set_music_volume(volume: float):
	current_volume = volume
	var db = linear_to_db(volume)
	player_main.volume_db = db
	player_battle.volume_db = db
