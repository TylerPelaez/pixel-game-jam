extends Node2D
class_name Core

signal death_started
signal died

@export var no_damage_texture: Texture2D
@export var light_damage_texture: Texture2D
@export var medium_damage_texture: Texture2D
@export var heavy_damage_texture: Texture2D

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var stats: Stats = $Stats
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var healthbar: HealthBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite2D

var dying = false

func _reset():
	stats.health_changed.connect(_on_stats_health_changed)

func _on_stats_no_health():
	death_started.emit()
	dying = true

func play_death_animation():
	animation_player.play("Death")

func _on_hurtbox_area_entered(area: Area2D):
	if area is Hitbox and !hurtbox.invincible and !dying:
		got_hit(area.damage)

func got_hit(damage):
	stats.health -= damage
	if stats.health > 0 and damage > 0:
		hurtbox.start_invincibility(stats.hit_invincibility_time_seconds)
		_invincibility_started()
		hurtbox.create_hit_effect()
	
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
	animation_player.play("Flash")

func _on_death_animation_complete():
	died.emit()
	queue_free()

func _on_stats_health_changed(value):
	healthbar.update(stats.health, stats.max_health)
