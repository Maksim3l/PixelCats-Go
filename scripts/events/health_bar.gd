extends ProgressBar

@onready var label = $HealthLabel

func _ready():
	label.text = str(value)

func _on_value_changed(value):
	label.text = str(value)
