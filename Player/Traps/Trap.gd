extends Node2D
class_name Trap

signal on_death(trap: Node2D)

@export var id: TrapData.TrapId
@export var attack_capable: bool = true
@export var attack_cooldown: float = 1.0

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var nav_collision_polygon: CollisionPolygon2D = $NavCollider/CollisionPolygon2D
@onready var stats: Stats = $Stats
@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var deployed = false

func _ready():
	animation_player.play("Deploy")

var is_attacking := false

func _on_deploy_complete():
	deployed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !deployed: 
		return
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

func _on_stats_no_health():
	on_death.emit(self)
	queue_free()

func _on_hurtbox_area_entered(area):
	if area is Hitbox:
		stats.health -= area.damage
