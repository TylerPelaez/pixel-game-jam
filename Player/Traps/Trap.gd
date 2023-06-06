extends Node2D
class_name Trap

@export var attack_capable: bool = true
@export var attack_cooldown: float = 1.0

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var nav_collision_polygon: CollisionPolygon2D = $NavCollider/CollisionPolygon2D


var is_attacking := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if should_attack():
		attack()

# Implement in children
func attack() -> void:
	is_attacking = true

func should_attack() -> bool:
	return !is_attacking && attack_cooldown_timer.time_left <= 0

func on_attack_finished():
	attack_cooldown_timer.start(attack_cooldown)
	is_attacking = false
