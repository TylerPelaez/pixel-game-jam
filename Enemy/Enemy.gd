extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)

@export var ACCELERATION := 500
@export var MAX_SPEED := 100
@export var FRICTION := 500
@export var PUSH_STRENGTH := 2000

enum State {
	MOVE,
	SPAWN,
	ATTACK,
	DYING,
	WAITING_TO_ATTACK
}

var target: Node2D
var state: State = State.MOVE
var scratch_velocity: Vector2 = Vector2.ZERO

@export var attack_check_distance = 24

@onready var stats: Stats = $Stats
@onready var hurtbox = $Hurtbox
@onready var blink_animation_player = $BlinkAnimationPlayer
@onready var soft_collision = $SoftCollision

@onready var sprite: Sprite2D = $Sprite2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D

# initialize as if it was being initialized in _ready
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

@onready var attack_raycast: RayCast2D = $RayCast2D
@onready var hands: Node2D = $Hands

@onready var health_bar: HealthBar = $HealthBar

var attacking_core: bool = false
var attack_target_pos: Vector2

var last_attack_start: float 
var waiting_to_attack_target_pos: Vector2
var waiting_to_attack_core: bool

var attack_damage_started: bool

func _ready():
	reset()

func reset():
	state = State.SPAWN
	var cores = get_tree().get_nodes_in_group(&"Core")
	if cores.size() != 1:
		push_error("Found Non-1 number of cores!")
		return
	target = cores[0]
	
	animation_tree.active = true
	
	scratch_velocity = Vector2.ZERO

	stats.reset()
	
	agent.set_target_position(target.global_position)

# Update
func _physics_process(delta):
	match state:
		State.WAITING_TO_ATTACK:
			waiting_to_attack_state(delta)
		State.MOVE:
			move_state(delta)
		State.ATTACK:
			attack_state(delta)

func _on_spawn_finished():
	state = State.MOVE

func waiting_to_attack_state(delta):
	scratch_velocity = scratch_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()
	
	# Check if enemy has been knocked back out of attack range
	if global_position.distance_to(waiting_to_attack_target_pos) > attack_check_distance:
		state = State.MOVE
		waiting_to_attack_core = false
		return
	if !is_attack_on_cooldown():
		start_attack(waiting_to_attack_target_pos, waiting_to_attack_core)

func move_state(delta):
	var next_path_pos = agent.get_next_path_position()
	if global_position.distance_to(next_path_pos) < attack_check_distance:
		var target_pos = next_path_pos - global_position
		attack_raycast.target_position = target_pos.normalized() * (target_pos.length() + 1)
		attack_raycast.force_raycast_update()
		if attack_raycast.is_colliding():
			var layer = attack_raycast.get_collider().collision_layer
			var is_core = (layer & 0b10_00000000) > 0; # Core layer is # 10
			
			var attack_target_pos = attack_raycast.get_collider().global_position
			
			if is_attack_on_cooldown():
				state = State.WAITING_TO_ATTACK
				waiting_to_attack_target_pos = attack_target_pos
				waiting_to_attack_core = is_core
				return

			start_attack(attack_target_pos, is_core)
			return
	
	var input_vector = (next_path_pos - global_position).normalized()
	
	# TODO: Different Move/Idle animation?
	animation_state.travel("Idle")
	
	if input_vector != Vector2.ZERO:
		scratch_velocity = scratch_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animation_tree.set("parameters/Idle/blend_position", scratch_velocity.x)
		animation_tree.set("parameters/Attack/blend_position", scratch_velocity.x)
	else:
		scratch_velocity = scratch_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	if soft_collision.is_colliding():
		scratch_velocity += soft_collision.get_push_vector() * delta * PUSH_STRENGTH
	
	move()

func is_attack_on_cooldown():
	return Time.get_ticks_msec() - last_attack_start < (stats.attack_cooldown_seconds * 1000)

func start_attack(_attack_target_pos: Vector2, is_core_attack: bool):
	state = State.ATTACK
	attack_target_pos = _attack_target_pos
	hands.global_position = _attack_target_pos
	animation_tree.set("parameters/Attack/blend_position", (agent.get_next_path_position() - global_position).normalized().x)
	animation_state.travel("Attack")
	attacking_core = is_core_attack
	last_attack_start = Time.get_ticks_msec()
	attack_damage_started = false
	
func attack_state(delta):
	hands.global_position = attack_target_pos

func _on_attack_complete():
	if attacking_core:
		die()
		return
	state = State.MOVE
	animation_state.travel("Idle")

func move():
	set_velocity(scratch_velocity)
	move_and_slide()
	scratch_velocity = velocity

func _on_Hurtbox_area_entered(area: Area2D):
	if area is Hitbox && !hurtbox.invincible && state != State.DYING:
		got_hit(area.damage)

func got_hit(damage):
	stats.health -= damage
	hurtbox.start_invincibility(stats.hit_invincibility_time_seconds)
	_invincibility_started()
	hurtbox.create_hit_effect()

func knockback(strength: float, source_pos: Vector2):
	var direction = (global_position - source_pos).normalized()
	var distance = global_position.distance_to(source_pos)
	var offset = (direction * strength)
	scratch_velocity += offset
	velocity += offset
	
	if state == State.ATTACK && !attack_damage_started:
		state = State.MOVE
		animation_state.travel("Idle")
		attacking_core = false

func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Blink/Stop")

func _invincibility_started():
	blink_animation_player.play("Blink/Start")

func _on_stats_no_health():
	die()

func die():
	state = State.DYING
	animation_state.travel("Death")

func _on_stats_health_changed(value):
	health_bar.update(stats.health, stats.max_health)

func _on_stats_max_health_changed(value):
	health_bar.update(stats.health, stats.max_health)

func _on_death_animation_finished():
	died.emit(self)
	queue_free()

func is_flipped():
	return sprite.flip_h

func set_attack_damage_started():
	attack_damage_started = true
