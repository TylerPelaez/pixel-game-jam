extends Sprite2D

signal complete

func _on_animation_complete():
	complete.emit()
