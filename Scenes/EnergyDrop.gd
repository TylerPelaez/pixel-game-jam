extends Node2D

signal collected(amount: int)

@onready var sprite: Sprite2D = $Sprite2D
var amount: int = 10

func set_flipped(value: bool):
	sprite.flip_h = value

func _on_area_2d_area_entered(area):
	collected.emit(amount)
	queue_free()

func _on_area_2d_body_entered(body):
	collected.emit(amount)
	queue_free()
