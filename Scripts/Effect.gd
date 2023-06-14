extends Sprite2D

signal complete

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	var seek_time = animation_player.get_animation("Effect").length * randf()
	animation_player.play("Effect")
	animation_player.seek(seek_time, true)

func _on_animation_complete():
	complete.emit()
	queue_free()
	
