extends Area2D
class_name Hurtbox

#const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false: set = set_invincible

@onready var timer = $Timer
@onready var collision_shape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
	

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	pass
#	var effect = HitEffect.instantiate()
#	var world = get_tree().current_scene
#	world.add_child(effect)
#	effect.global_position = global_position


func _on_Hurtbox_invincibility_started():
	collision_shape.set_deferred("disabled", true)

func _on_Hurtbox_invincibility_ended():
	collision_shape.disabled = false

func _on_timer_timeout():
	# This calls the setter defined near setget, because we've indicated self
	self.invincible = false
