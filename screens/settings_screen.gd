extends Node2D

@onready var music_slider = $music
@onready var music_manager = get_node("/root/MusicManager")
@onready var master_slider = $master

@onready var audio = $UITopLeft/AudioStreamPlayer2D2

func _on_back_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	_load_scene("res://screens/idle_screen.tscn")

func _load_scene(scene_path):
	var new_scene = load(scene_path).instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func _on_master_slider_changed(value: float):
	var db = linear_to_db(value)
	var master_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_index, db)
	save_master_volume(value)

func save_master_volume(value: float):
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		print("Could not load settings.cfg, creating new")
	config.set_value("audio", "master_volume", value)
	config.save("user://settings.cfg")

func _ready():
	# Poveži slider
	master_slider.value_changed.connect(_on_master_slider_changed)
	load_volume_settings()
	music_slider.value_changed.connect(_on_music_slider_changed)

	# Naloži shranjene nastavitve
	load_volume_settings()

func _on_music_slider_changed(value: float):
	# Posodobi MusicManager
	music_manager.set_music_volume(value)

	# Shrani nastavitve
	save_volume_settings(value)

func save_volume_settings(volume: float):
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", volume)
	config.save("user://settings.cfg")

func load_volume_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var volume = config.get_value("audio", "music_volume", 1.0)
		music_slider.value = volume
		music_manager.set_music_volume(volume)
	var master_volume = config.get_value("audio", "master_volume", 1.0)
	master_slider.value = master_volume
	var master_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_index, linear_to_db(master_volume))
