extends Trap
class_name LaserTrap

var last_target: Enemy
var current_target: Enemy

func attack() -> void:
	super.attack()
	current_target = last_target
	last_target = null
	animation_player.play(&"Attack")

func should_attack() -> bool:
	if super.should_attack():
		# Do collision check in radius around
		shape_cast.force_shapecast_update()
		var collision_count = shape_cast.get_collision_count()
		if collision_count == 0:
			return false
		
		var min_distance = 999999
		var closest_collider
		for i in collision_count:
			var collider = shape_cast.get_collider(i)
			if collider is Node2D:
				var distance = collider.global_position.distance_to(global_position)
				if distance < min_distance:
					min_distance = distance
					closest_collider = collider
					
		# TODO: Clean this up, expecting a lot from the trap attack flow for this to work correctly
		last_target = closest_collider.get_parent()
		
		return true
	else:
		return false
		
func _on_attack():
	print("pew")
