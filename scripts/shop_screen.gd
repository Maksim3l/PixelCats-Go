extends Node2D

@onready var audio = $"Organizer/UITopLeft/AudioStreamPlayer2D2"
@onready var treat = $"Organizer/UITop/ProfileUI/Treat/value"
@onready var energy = $"Organizer/UITop/ProfileUI/Energy/value"
@onready var gold = $"Organizer/UITop/ProfileUI/Gold/value"

@onready var treat_button = $"Organizer/UICenterBG/AccessoryPanel/Treat/Buy"
@onready var crown_button = $"Organizer/UICenterBG/AccessoryPanel/Crown/Buy"
@onready var glasses_button = $"Organizer/UICenterBG/AccessoryPanel/Glasses/Buy"
@onready var mask_button = $"Organizer/UICenterBG/AccessoryPanel/Mask/Buy"
@onready var ninja_button = $"Organizer/UICenterBG/AccessoryPanel/Ninja/Buy"
@onready var swim_button = $"Organizer/UICenterBG/AccessoryPanel/Swim/Buy"
@onready var robot_arm_button = $"Organizer/UICenterBG/AccessoryPanel/RobotArm/Buy"
@onready var belt_button = $"Organizer/UICenterBG/AccessoryPanel/Belt/Buy"
@onready var tie_button = $"Organizer/UICenterBG/AccessoryPanel/Tie/Buy"
@onready var energy_button = $"Organizer/UICenterBG/AccessoryPanel/Energy/Buy"


var accessory_prices = {
	"treat": 100,
	"crown": 800,
	"glasses": 200,
	"mask": 100,
	"ninja": 400,
	"swim": 150,
	"robot_arm": 700,
	"belt": 300,
	"tie": 100,
	"energy": 300
}

var accessory_buttons = {}

func _ready():
	MusicManager.play_main_music()
	var global_data = GlobalDataHandler.global_data
	var active_cat = CatHandler.get_active_cat()

	# Prikaz trenutnega zlata, treatov in energije
	gold.text = str(global_data.gold)
	treat.text = str(global_data.treat)
	energy.text = str(active_cat.max_energy) + "/" + str(active_cat.energy)

	# seznam gumbov za dodatke
	accessory_buttons = {
		"treat": treat_button,
		"crown": crown_button,
		"glasses": glasses_button,
		"mask": mask_button,
		"ninja": ninja_button,
		"swim": swim_button,
		"robot_arm": robot_arm_button,
		"belt": belt_button,
		"tie": tie_button,
		"energy": energy_button
	}

	update_button_states()

func update_button_states():
	var global_data = GlobalDataHandler.global_data
	var active_cat = CatHandler.get_active_cat()

	for item_name in accessory_prices.keys():
		var button = accessory_buttons.get(item_name, null)
		var price = accessory_prices[item_name]

		if item_name == "energy":
			# Onemogoči energy gumb, če ima igralec že največ energije (3)
			if active_cat.energy >= 3 or global_data.gold < price:
				button.disabled = true
			else:
				button.disabled = false
		elif item_name == "treat":
			# Onemogoči treat gumb, če ima igralec že največ treatov (3)
			if global_data.treat >= 3 or global_data.gold < price:
				button.disabled = true
			else:
				button.disabled = false
		else:
			# Onemogoči gumb, če je dodatek že kupljen ali če igralec nima dovolj zlata
			if GlobalDataHandler.has_accessory(item_name) or global_data.gold < price:
				button.disabled = true
			else:
				button.disabled = false

func buy_item(item_name):
	var global_data = GlobalDataHandler.global_data
	var active_cat = CatHandler.get_active_cat()
	var price = accessory_prices[item_name]

	if global_data.gold >= price:
		global_data.gold -= price
		gold.text = str(global_data.gold)

		if item_name == "treat":
			if global_data.treat < 3:
				global_data.treat += 1
				treat.text = str(global_data.treat)
		elif item_name == "energy":
			if active_cat.energy < 3:
				active_cat.energy += 1
				energy.text = str(active_cat.max_energy) + "/" + str(active_cat.energy)
		else:
			GlobalDataHandler.add_accessory(item_name)

		GlobalDataHandler.save_game()
		update_button_states()

		print(item_name.capitalize() + " kupljen!")
	else:
		print("Nimaš dovolj zlata za " + item_name.capitalize() + "!")

func _on_back_pressed():
	audio.play()
	await get_tree().create_timer(0.25).timeout
	_load_scene("res://screens/idle_screen.tscn")

func _load_scene(scene_path):
	var new_scene = load(scene_path).instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

func _on_TreatButton_pressed():
	buy_item("treat")

func _on_CrownButton_pressed():
	buy_item("crown")

func _on_GlassesButton_pressed():
	buy_item("glasses")

func _on_MaskButton_pressed():
	buy_item("mask")

func _on_NinjaButton_pressed():
	buy_item("ninja")

func _on_SwimButton_pressed():
	buy_item("swim")

func _on_RobotArmButton_pressed():
	buy_item("robot_arm")

func _on_BeltButton_pressed():
	buy_item("belt")
	
func _on_TieButton_pressed():
	buy_item("tie")
	
func _on_EnergyButton_pressed():
	buy_item("energy")
