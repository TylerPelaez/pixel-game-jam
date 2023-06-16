extends Node2D
class_name GameController

signal inventory_updated(inventory: Inventory)
signal new_wave(wave_number: int)
signal game_lost(wave_number: int, time_elapsed: int)

signal player_moved
signal player_meleed
signal radial_menu_opened
signal trap_placed
signal wave_started
signal trap_cancelled
signal player_died
signal loss_started

@onready var grid_controller: GridController = $GridController

@onready var nav_controller: NavController = $NavigationRegion2D
@onready var spawners: Node2D = $Spawners
@onready var radial_menu_follow = $RadialMenuObjects/RadialMenuFollow
@onready var radial_menu: RadialMenu = $RadialMenuObjects/RadialMenuFollow/RadialMenu

@onready var player_spawner: Node2D = $PlayerSpawnLocation

@onready var core: Core = $Core
@onready var core_death_orchestrator = $CoreDeathOrchestrator 

@onready var spawner_visuals_animation_player: AnimationPlayer = $SpawnerVisuals/AnimationPlayer

@onready var inventory: Inventory = $Inventory
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var left_spawner: Node2D = $Spawners/Left
@onready var down_spawner: Node2D = $Spawners/Down
@onready var right_spawner: Node2D = $Spawners/Right

@export var enemy_prefab: PackedScene
@export var enemy_variant_prefab: PackedScene


@export var energy_drop_prefab: PackedScene
@export var starting_energy: int = 50
@export var player_prefab: PackedScene = preload("res://Player/PlayerController.tscn")
@export var starting_wave: int = 1

var player: PlayerController

var wave_counter: int
var current_wave_makeup: WaveData.WaveMakeup
var regular_enemies_spawned: int
var variant_enemies_spawned: int

var wave_active: bool = false
var wave_start_time: float
var dead_enemies_count: int

var start_time

var loss_animation_started: bool = false

func _ready():
	wave_counter = starting_wave
	start_time = Time.get_ticks_msec()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	spawn_player()
	
	grid_controller.placement_started.connect(player.on_placement_started)
	grid_controller.placement_started.connect(radial_menu_follow.start_follow_mouse)
	grid_controller.placement_ended.connect(player.on_placement_ended)
	grid_controller.placement_ended.connect(radial_menu_follow.begin_stop_follow_mouse)
	
	grid_controller.placement_ended.connect(func(): trap_cancelled.emit())
	
	grid_controller.placed_trap.connect(func(trap: Trap): nav_controller.add_structure(trap, trap.nav_collision_polygon))
	grid_controller.placed_trap.connect(func(trap): if player != null: player.on_placement())
	grid_controller.placed_trap.connect(func(trap): trap_placed.emit())	
	
	core.death_started.connect(core_death_start)
	core.died.connect(func(): game_lost.emit(wave_counter - 1, Time.get_ticks_msec() - start_time))
	
	radial_menu.opened.connect(on_radial_menu_opened)
	radial_menu.closed.connect(on_radial_menu_closed)
	
	inventory.updated.connect(func(_val): inventory_updated.emit(inventory))
	inventory.updated.connect(func(_val): radial_menu.energy_count_updated(_val.energy))
	inventory_updated.emit(inventory)
	
	player.moved.connect(func(): player_moved.emit())
	player.attacked.connect(func(): player_meleed.emit())
	
	pre_wave()


func spawn_player():
	player = player_prefab.instantiate()
	grid_controller.player_revived()
	add_child(player)
	player.global_position = player_spawner.global_position
	player.died.connect(on_player_death)

func on_player_death():
	player_died.emit()
	grid_controller.on_player_death()
	radial_menu.set_open(false)

func pre_wave():
	current_wave_makeup = WaveDataDB.get_wave_makeup(wave_counter)
	var wave_type: WaveData.WaveType = current_wave_makeup.type
	
	match wave_type:
		WaveData.WaveType.LEFT:
			spawner_visuals_animation_player.play("BlinkLeft")
		WaveData.WaveType.RIGHT:
			spawner_visuals_animation_player.play("BlinkRight")
		WaveData.WaveType.BOTTOM:
			spawner_visuals_animation_player.play("BlinkDown")
		WaveData.WaveType.ALL:
			spawner_visuals_animation_player.play("BlinkAll")

func start_wave():
	regular_enemies_spawned = 0
	variant_enemies_spawned = 0
	dead_enemies_count = 0
	wave_start_time = Time.get_ticks_msec()
	wave_active	= true
	wave_started.emit()

func end_wave():
	core.got_hit(-current_wave_makeup.core_health_reward)
	if player != null:
		player.got_hit(-current_wave_makeup.player_health_reward)
	MusicController.dim_game_music_for_wave_complete()
	audio_player.play()
	wave_counter += 1
	wave_active = false
	new_wave.emit(wave_counter)
	pre_wave()

func _process(delta):
	if loss_animation_started:
		get_tree().call_group("Energy", "queue_free")
	
	var enemies_spawned = regular_enemies_spawned + variant_enemies_spawned
	var enemy_spawn_limit = current_wave_makeup.regular_enemy_count + current_wave_makeup.variant_enemy_count
	
	if !wave_active and !loss_animation_started:
		if Input.is_action_just_pressed("Start Wave"):
			start_wave()
	elif enemies_spawned < enemy_spawn_limit:
		var now = Time.get_ticks_msec()
		var wave_time_progress = float(now - wave_start_time) / float(current_wave_makeup.spawn_duration_seconds * 1000.0)
		var wave_spawn_progress = float(enemies_spawned) / float(enemy_spawn_limit)
		if wave_time_progress > wave_spawn_progress:
			spawn_enemy()

func _input(event):
	if loss_animation_started:
		return
	if event.is_action_pressed("Open Radial Menu") && player != null:
		radial_menu.set_open(true)
	elif event.is_action_released("Open Radial Menu"):
		radial_menu.set_open(false)

func spawn_enemy():
	var spawner_parent
	match current_wave_makeup.type:
		WaveData.WaveType.LEFT:
			spawner_parent = left_spawner
		WaveData.WaveType.BOTTOM:
			spawner_parent = down_spawner
		WaveData.WaveType.RIGHT:
			spawner_parent = right_spawner
		WaveData.WaveType.ALL:
			var random = randf()
			if random < 0.33:
				spawner_parent = left_spawner
			elif random < 0.66:
				spawner_parent = down_spawner
			else :
				spawner_parent = right_spawner  
	
	
	var pos_a: Vector2 = spawner_parent.get_child(0).global_position
	var pos_b: Vector2 = spawner_parent.get_child(1).global_position
	var r = randf()
	var r2 = randf()
	
	var spawn_pos = pos_a + Vector2((pos_b.x - pos_a.x) * r, (pos_b.y - pos_a.y)  * r2)
	
	var distribution: WaveData.EnemyDistribution = current_wave_makeup.distribution
	var enemy_to_spawn: PackedScene = enemy_prefab
	
	var regular_enemies_ratio := float(regular_enemies_spawned) / float(current_wave_makeup.regular_enemy_count)
	var variant_enemies_ratio := float(variant_enemies_spawned) / float(current_wave_makeup.variant_enemy_count)
	
	match distribution:
		WaveData.EnemyDistribution.MIXED:
			if variant_enemies_ratio < regular_enemies_ratio:
				enemy_to_spawn = enemy_variant_prefab
		WaveData.EnemyDistribution.VARIANT_FIRST:
			if variant_enemies_ratio < 1:
				enemy_to_spawn = enemy_variant_prefab
		WaveData.EnemyDistribution.VARIANT_LAST:
			if regular_enemies_ratio >= 1:
				enemy_to_spawn = enemy_variant_prefab
	
	var enemy = enemy_to_spawn.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_pos
	enemy.died.connect(on_enemy_died)
	if enemy_to_spawn == enemy_variant_prefab:
		variant_enemies_spawned += 1
	else:
		regular_enemies_spawned += 1

func on_enemy_died(enemy: Enemy):
	var energy = energy_drop_prefab.instantiate()
	energy.global_position = enemy.global_position
	energy.collected.connect(_on_energy_collected)
	call_deferred("add_child", energy)
	energy.call_deferred("set_flipped", enemy.is_flipped())
	
	dead_enemies_count += 1
	if dead_enemies_count >= current_wave_makeup.regular_enemy_count + current_wave_makeup.variant_enemy_count && !loss_animation_started:
		end_wave()
	
func _on_energy_collected(amount: int):
	inventory.energy += amount

func on_radial_menu_opened():
	radial_menu_follow.menu_open = true
	grid_controller.on_radial_menu_opened()
	radial_menu_opened.emit()
	if radial_menu_follow.follow_mouse:
		radial_menu_follow.start_follow_mouse()

func on_radial_menu_closed():
	radial_menu_follow.menu_open = false
	var current_trap = radial_menu.get_currently_selected_trap()
	if current_trap != null && grid_controller.state != GridController.State.PLAYER_DEAD:
		grid_controller.start_placing(current_trap)

func core_death_start():
	loss_animation_started = true

	radial_menu.set_open(false)
	grid_controller.finish_placement()
	wave_active = false
	get_tree().call_group("Enemy", "die")
	get_tree().call_group("Trap", "queue_free")
	
	loss_started.emit()
	
	if player != null:
		player.healthbar.visible = false
	core_death_orchestrator.play("Death")
	
func on_orchestrator_complete():
	core.play_death_animation()

func grant_starting_energy():
	inventory.energy += starting_energy

func get_wave_enemies_remaining():
	return current_wave_makeup.regular_enemy_count + current_wave_makeup.variant_enemy_count - dead_enemies_count
