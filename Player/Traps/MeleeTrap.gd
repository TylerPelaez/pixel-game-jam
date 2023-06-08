extends Trap


@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Implement in children
func attack() -> void:
	super.attack()
	animation_player.play(&"Attack")

func should_attack() -> bool:
	if super.should_attack():
		# Do collision check in radius around
		shape_cast.force_shapecast_update()
		return shape_cast.is_colliding()
	else:
		return false
