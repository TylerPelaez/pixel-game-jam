extends Trap
class_name LaserTrap

@onready var laser_source: Sprite2D = $LaserSource
@onready var laser_pivot: Node2D = $LaserPivot
@onready var laser_beam: Sprite2D = $LaserPivot/LaserBase/LaserBeam

var last_target: Enemy
var current_target: Enemy

var laser_beam_size: float
var laser_beam_initial_offset: float

func _ready():
	super._ready()
	laser_beam_size = laser_beam.texture.get_size().y
	laser_beam_initial_offset = laser_beam.offset.y

func _process(delta):
	if !deployed: 
		return
	
	if is_attacking:
		if current_target == null:
			animation_player.play("RESET")
			on_attack_finished()
			return
			
		laser_pivot.rotation = laser_pivot.global_position.angle_to_point(current_target.global_position)
		laser_beam.scale.y = (laser_pivot.global_position.distance_to(current_target.global_position) / laser_beam_size)
	
	if should_attack():
		attack()

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
			if collider is Node2D and collider.get_parent().state != Enemy.State.DYING:
				var distance = collider.global_position.distance_to(global_position)
				if distance < min_distance:
					min_distance = distance
					closest_collider = collider
		
		if closest_collider == null:
			return false
		
		# TODO: Clean this up, expecting a lot from the trap attack flow for this to work correctly
		last_target = closest_collider.get_parent()
		
		return true
	else:
		return false

func do_damage():
	if is_attacking && current_target != null:
		current_target.got_hit(1)
