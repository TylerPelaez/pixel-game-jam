extends Trap

@onready var shape_cast: ShapeCast2D = $AttackCast
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Implement in children
func attack() -> void:
	super.attack()
	animation_player.play(&"Attack")

func should_attack() -> bool:
	if !is_attacking:
		# Do collision check in radius around
		shape_cast.force_shapecast_update()
		return shape_cast.is_colliding()
	else:
		return false

func on_attack_finished():
	on_death.emit(self)
	queue_free()

func _on_stats_no_health():
	attack()
	
