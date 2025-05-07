extends TextureProgressBar

@onready var label = $HealthLabel

func _ready():
	# Posodobi tekst
	update_label()

func _on_value_changed(value):
	update_label()

func update_label():
	label.text = str(value) + " / " + str(max_value)
