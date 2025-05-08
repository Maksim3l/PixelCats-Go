extends TextureProgressBar

func _ready():
	update_progress()

func set_max_health(value: int):
	max_value = value
	update_progress()

func set_current_health(value: int):
	self.value = clamp(value, 0, max_value)
	update_progress()

func update_progress():
	var progress_ratio = float(value) / float(max_value)

func _on_value_changed(new_value):
	update_progress()
