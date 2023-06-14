extends Node2D
class_name GameController

@onready var ui_controller: UIController = $"UI Controller"
@onready var grid_controller: GridController = $GridController
@onready var player: PlayerController = $Player
@onready var nav_controller: NavController = $NavigationRegion2D
@onready var spawners: Node2D = $Spawners
@onready var radial_menu_follow = $RadialMenuObjects/RadialMenuFollow
@onready var radial_menu: RadialMenu = $RadialMenuObjects/RadialMenuFollow/RadialMenu

@onready var spawner_visuals_animation_tree: AnimationTree = $SpawnerVisuals/AnimationTree

@onready var inventory: Inventory = $Inventory

@export var enemy_prefab: PackedScene
@export var enemies_per_wave_level = 30
@export var enemy_spawn_distance = 450
@export var wave_spawn_time_seconds: float = 30.0
@export var energy_drop_prefab: PackedScene

var wave_counter: int = 1
var wave_enemy_spawn_limit: int
var spawned_enemies_count: int
var wave_active: bool = false
var wave_start_time: float
var dead_enemies_count: int
var active_spawner_parent: Node2D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	grid_controller.placement_started.connect(player.on_placement_started)
	grid_controller.placement_started.connect(radial_menu_follow.start_follow_mouse)
	grid_controller.placement_ended.connect(player.on_placement_ended)
	grid_controller.placement_ended.connect(radial_menu_follow.begin_stop_follow_mouse)
	grid_controller.placed_trap.connect(func(trap: Trap): nav_controller.add_structure(trap, trap.nav_collision_polygon))
	grid_controller.placed_trap.connect(func(trap): player.on_placement())
	
	radial_menu.opened.connect(on_radial_menu_opened)
	radial_menu.closed.connect(on_radial_menu_closed)
	
	spawner_visuals_animation_tree.active = true
	inventory.updated.connect(ui_controller.on_inventory_updated)
	ui_controller.on_inventory_updated(inventory)
	pre_wave()

func pre_wave():
	active_spawner_parent = spawners.get_child(randi_range(0, spawners.get_child_count() - 1))
#	var direction = (active_spawner_parent.global_position - spawners.global_position).normalized()
#	spawner_visuals_animation_tree.set("parameters/blend_position", direction)

func start_wave():
	spawned_enemies_count = 0
	dead_enemies_count = 0
	wave_enemy_spawn_limit = enemies_per_wave_level * wave_counter
	wave_start_time = Time.get_ticks_msec()
	wave_active	= true

func end_wave():
	wave_counter += 1
	wave_active = false
	ui_controller.new_wave(wave_counter)
	pre_wave()

func _process(delta):
	if !wave_active:
		if Input.is_action_just_pressed("Start Wave"):
			start_wave()
	elif spawned_enemies_count < wave_enemy_spawn_limit:
		var now = Time.get_ticks_msec()
		var wave_time_progress = float(now - wave_start_time) / float(wave_spawn_time_seconds * 1000.0)
		var wave_spawn_progress = float(spawned_enemies_count) / float(wave_enemy_spawn_limit)
		if wave_time_progress > wave_spawn_progress:
			spawn_enemy()

func _input(event):
	if event.is_action_pressed("Open Radial Menu"):
		radial_menu.set_open(true)
	elif event.is_action_released("Open Radial Menu"):
		radial_menu.set_open(false)

func spawn_enemy():
	var player_pos = player.global_position
	var pos_a: Vector2 = active_spawner_parent.get_child(0).global_position
	var pos_b: Vector2 = active_spawner_parent.get_child(1).global_position
	var r = randf()
	var r2 = randf()
	
	var spawn_pos = pos_a + Vector2((pos_b.x - pos_a.x) * r, (pos_b.y - pos_a.y)  * r2)
	
	var enemy = enemy_prefab.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_pos
	spawned_enemies_count += 1
	enemy.died.connect(on_enemy_died)

func on_enemy_died(enemy: Enemy):
	var energy = energy_drop_prefab.instantiate()
	energy.global_position = enemy.global_position
	energy.collected.connect(_on_energy_collected)
	call_deferred("add_child", energy)
	energy.call_deferred("set_flipped", enemy.is_flipped())
	
	dead_enemies_count += 1
	if dead_enemies_count >= wave_enemy_spawn_limit:
		end_wave()
	
func _on_energy_collected(amount: int):
	inventory.energy += amount

func on_radial_menu_opened():
	radial_menu_follow.menu_open = true
	grid_controller.on_radial_menu_opened()
	if radial_menu_follow.follow_mouse:
		radial_menu_follow.start_follow_mouse()

func on_radial_menu_closed():
	radial_menu_follow.menu_open = false
	var current_trap = radial_menu.get_currently_selected_trap()
	if current_trap != null:
		grid_controller.start_placing(current_trap)
