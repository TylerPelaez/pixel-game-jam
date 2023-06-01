extends CharacterBody2D
class_name Enemy

signal died

@export var ACCELERATION := 500
@export var MAX_SPEED := 100
@export var FRICTION := 500
@export var PUSH_STRENGTH := 2000

enum State {
	MOVE
}

var target: Node2D
var state: State = State.MOVE
var scratch_velocity: Vector2 = Vector2.ZERO

@onready var stats: Stats = $Stats
@onready var hurtbox = $Hurtbox
@onready var blink_animation_player = $BlinkAnimationPlayer
@onready var soft_collision = $SoftCollision

# initialize as if it was being initialized in _ready
#@onready var animationTree = $AnimationTree
#@onready var animationState = animationTree.get("parameters/playback")

func _ready():
	reset()

func reset():
	state = State.MOVE
	var cores = get_tree().get_nodes_in_group(&"Core")
	if cores.size() != 1:
		push_error("Found Non-1 number of cores!")
		return
	target = cores[0]
	
#	animationTree.active = true
	
	scratch_velocity = Vector2.ZERO

	stats.reset()

# Update
func _physics_process(delta):
	match state:
		State.MOVE:
			move_state(delta)
	
func move_state(delta):
	var input_vector = (target.global_position - global_position).normalized()
	
	if input_vector != Vector2.ZERO:
		scratch_velocity = scratch_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		scratch_velocity = scratch_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	if soft_collision.is_colliding():
		scratch_velocity += soft_collision.get_push_vector() * delta * PUSH_STRENGTH
	
	move()

func move():
	set_velocity(scratch_velocity)
	move_and_slide()
	scratch_velocity = velocity
	
func _on_Hurtbox_area_entered(area: Area2D):
	if area is Hitbox && !hurtbox.invincible:
		got_hit(area.damage)

func got_hit(damage):
	stats.health -= damage
	hurtbox.start_invincibility(stats.hit_invincibility_time_seconds)
	_invincibility_started()
	hurtbox.create_hit_effect()

func _on_Hurtbox_invincibility_ended():
	blink_animation_player.play("Blink/Stop")

func _invincibility_started():
	blink_animation_player.play("Blink/Start")

func _on_stats_no_health():
	emit_signal("died")
	queue_free()
