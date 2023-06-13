extends Trap

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

func _on_knockback_area_entered(area):
	if area.get_parent() is Enemy:
		area.get_parent().knockback(stats.knockback_strength, global_position)
