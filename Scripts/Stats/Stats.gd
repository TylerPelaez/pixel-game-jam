extends Node
class_name Stats

@export var max_health: int = 1: set = set_max_health
var health = max_health: set = set_health

@export var knockback_strength: float = 1.0

@export var hit_invincibility_time_seconds: float = 0.6

@export var attack_cooldown_seconds: float = 0.5

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func _ready():
	reset()

func reset():
	self.health = max_health
