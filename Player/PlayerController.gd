extends CharacterBody2D
class_name PlayerController

signal died

@export var ACCELERATION := 500
@export var MAX_SPEED := 100
@export var FRICTION := 500

enum State {
	MOVE
}

var state: State = State.MOVE
var scratch_velocity: Vector2 = Vector2.ZERO

@onready var stats: Stats = $Stats
@onready var hurtbox = $Hurtbox
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer

# initialize as if it was being initialized in _ready
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

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
		State.MOVE:
			move_state(delta)
	
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
		animation_state.travel("Idle")
		scratch_velocity = scratch_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()

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
