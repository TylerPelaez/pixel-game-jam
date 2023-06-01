extends Node2D
class_name GameController

@export var enemy_prefab: PackedScene
@export var player: PlayerController
@export var enemies_per_wave_level = 30
@export var enemy_spawn_distance = 450
@export var wave_spawn_time_seconds: float = 30.0

var wave_counter: int = 1
var wave_enemy_spawn_limit: int
var spawned_enemies_count: int
var wave_active: bool = false
var wave_start_time: float

func _ready():
	start_wave()

func start_wave():
	spawned_enemies_count = 0
	wave_enemy_spawn_limit = enemies_per_wave_level * wave_counter
	wave_start_time = Time.get_ticks_msec()
	wave_active	= true
	
func _process(delta):
	if !wave_active:
		return
	
	if spawned_enemies_count < wave_enemy_spawn_limit:
		var now = Time.get_ticks_msec()
		var wave_time_progress = float(now - wave_start_time) / float(wave_spawn_time_seconds * 1000.0)
		var wave_spawn_progress = float(spawned_enemies_count) / float(wave_enemy_spawn_limit)
		if wave_time_progress > wave_spawn_progress:
			spawn_enemy()
	
func spawn_enemy():
	var player_pos = player.global_position
	
	var theta = randf() * TAU # angle to place enemy at
	var spawn_pos = player_pos + enemy_spawn_distance * Vector2(cos(theta), sin(theta))
	var enemy = enemy_prefab.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_pos
	spawned_enemies_count += 1
