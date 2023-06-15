extends Node2D
class_name Core

@export var no_damage_texture: Texture2D
@export var light_damage_texture: Texture2D
@export var medium_damage_texture: Texture2D
@export var heavy_damage_texture: Texture2D

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var stats: Stats = $Stats
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var healthbar: HealthBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite2D

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
	healthbar.update(stats.health, stats.max_health)
	
	var health_pct = float(stats.health) / float(stats.max_health)
	if health_pct > 0.66:
		sprite.texture = no_damage_texture
		sprite.hframes = 4
	elif health_pct <= 0.66 and health_pct > 0.4:
		sprite.texture = light_damage_texture
		sprite.hframes = 4
	elif health_pct <= 0.4 and stats.health > 1:
		sprite.texture = medium_damage_texture
		sprite.hframes = 4
	elif stats.health == 1:
		sprite.texture = heavy_damage_texture
		sprite.hframes = 1
		
func _on_Hurtbox_invincibility_ended():
	animation_player.play("RESET")

func _invincibility_started():
	if stats.health <= 0:
		# Play death anim
		print_debug("DIED AND ANIMATION ATTEMPT")
		return
	
	animation_player.play("Flash")
