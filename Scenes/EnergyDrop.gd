extends Node2D

signal collected(amount: int)

@onready var sprite: Sprite2D = $Sprite2D
var amount: int = 10

var being_sucked: bool = false
var suck_target: Node2D
var suck_speed: float = 100.0

var suck_complete_distance: float = 5

func _process(delta):
	if being_sucked:
		var to_target = global_position.direction_to(suck_target.global_position)
		global_position += to_target * suck_speed * delta
		if global_position.distance_to(suck_target.global_position) < suck_complete_distance:
			collected.emit(amount)
			queue_free()
	

func set_flipped(value: bool):
	sprite.flip_h = value

func _on_area_2d_area_entered(area):
	being_sucked = true
	suck_target = area


func _on_area_2d_area_exited(area):
	being_sucked = false
