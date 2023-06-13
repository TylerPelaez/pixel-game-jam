extends Node2D

signal collected(amount: int)

var amount: int = 10

func _on_area_2d_area_entered(area):
	collected.emit(amount)
	queue_free()

func _on_area_2d_body_entered(body):
	collected.emit(amount)
	queue_free()
