extends Trap

@export var explosion_count: int = 40
@export var explosion: PackedScene
@export var explosion_size: float = 1

@onready var proximity_cast: ShapeCast2D = $ProximityCast

var theta_constant = TAU / pow(1.618, 2.0)

func _ready():
	super._ready()

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
	is_dying = true
	queue_free()
	on_death.emit()

func _on_stats_no_health():
	attack()

func _physics_process(delta):
	if is_attacking || !deployed:
		return
	
	proximity_cast.force_shapecast_update()
	if proximity_cast.is_colliding():
		animation_player.play("Proximity")
	else:
		animation_player.play("RESET")

func spawn_explosions():
	for i in explosion_count:
		var theta = theta_constant * i
		var r = sqrt(i)
		
		var pos = global_position + Vector2.from_angle(theta) * r * explosion_size
		
		var instance = explosion.instantiate()
		get_tree().root.add_child(instance)
		instance.global_position =  pos
