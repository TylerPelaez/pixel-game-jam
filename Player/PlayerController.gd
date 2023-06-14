extends CharacterBody2D
class_name PlayerController

signal died
signal store_opened

@export var ACCELERATION := 500
@export var MAX_SPEED := 100
@export var FRICTION := 500

enum State {
	MOVE,
	PLACEMENT,
	ATTACK
}

var state: State = State.MOVE
var scratch_velocity: Vector2 = Vector2.ZERO

@onready var stats: Stats = $Stats
@onready var hurtbox = $Hurtbox
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer

# initialize as if it was being initialized in _ready
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var final_placement_animation_playing := false

var in_core_range: bool = false

func _ready():
	reset()

func reset():
	state = State.MOVE
	
	animation_tree.active = true
	
	scratch_velocity = Vector2.ZERO

	stats.reset()

# Update
func _physics_process(delta):
	match state:
		State.PLACEMENT:
			placement_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.MOVE:
			move_state(delta)

func placement_state(delta):	
	var mouse_direction_x = (get_global_mouse_position() - global_position).normalized().x
	animation_tree.set("parameters/PlacementOngoing/blend_position", mouse_direction_x)
	if !final_placement_animation_playing:
		animation_tree.set("parameters/PlacementComplete/blend_position", mouse_direction_x)
	
	move_state(delta)

func attack_state(delta):
	scratch_velocity = scratch_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_state.travel("Run")

		scratch_velocity = scratch_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		if state == State.PLACEMENT:
			animation_state.travel("PlacementOngoing" if !final_placement_animation_playing else "PlacementComplete")
		else:
			animation_state.travel("Idle")
		scratch_velocity = scratch_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("PlayerAttack"):
		start_attack()

func move():
	set_velocity(scratch_velocity)
	move_and_slide()
	scratch_velocity = velocity

func _on_Hurtbox_area_entered(area: Area2D):
	if area is Hitbox && !hurtbox.invincible:
		got_hit(area.damage)

func got_hit(damage: int):
	stats.health -= damage
	hurtbox.start_invincibility(stats.hit_invincibility_time_seconds)
	_invincibility_started()
	hurtbox.create_hit_effect()
#	var playerHurtSound = PlayerHurtSound.instantiate()
#	get_tree().current_scene.add_child(playerHurtSound)


func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Stop")

func _invincibility_started():
	blink_animation_player.play("Start")

#func pickup_health():
#	$ItemPickupPlayer.stream = PickupHealthSound
#	$ItemPickupPlayer.play()
#
#func pickup_shard():
#	$ItemPickupPlayer.stream = PickupGemSound
#	$ItemPickupPlayer.play()

func _on_stats_no_health():
	emit_signal("died")
	print("Died")

func on_placement_started():
	state = State.PLACEMENT
	final_placement_animation_playing = false
	
func on_placement():
	final_placement_animation_playing = true

func on_placement_animation_complete():
	final_placement_animation_playing = false

func on_placement_ended():
	state = State.MOVE
	final_placement_animation_playing = false

func start_attack():
	state = State.ATTACK
	animation_state.travel("KnockBack")

func on_attack_animation_complete():
	state = State.MOVE
	animation_state.travel("Idle")

func _on_knockback_area_entered(area: Node2D):
	if area.get_parent() is Enemy:
		area.get_parent().knockback(stats.knockback_strength, global_position)

func _on_core_range_detector_area_entered(area):
	in_core_range = true

func _on_core_range_detector_area_exited(area):
	in_core_range = false
