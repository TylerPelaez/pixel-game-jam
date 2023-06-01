extends Camera2D

@export var player:PlayerController

func _process(delta):
	position = player.position.floor()
	force_update_scroll()
