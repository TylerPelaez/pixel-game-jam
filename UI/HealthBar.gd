extends Control
class_name HealthBar

@onready var foreground: ColorRect = $Foreground

func update(current_health: int, max_health: int):
	foreground.scale.x = float(current_health) / max_health
