extends Node2D
class_name Core

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var stats: Stats = $Stats
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_stats_no_health():
	print("Core Dead!")
	queue_free()

func _on_hurtbox_area_entered(area: Area2D):
	if area is Hitbox and !hurtbox.invincible:
		got_hit(area.damage)

func got_hit(damage):
	stats.health -= damage
	hurtbox.start_invincibility(stats.hit_invincibility_time_seconds)
	_invincibility_started()
	hurtbox.create_hit_effect()

func _on_Hurtbox_invincibility_ended():
	animation_player.play("RESET")

func _invincibility_started():
	animation_player.play("Flash")
