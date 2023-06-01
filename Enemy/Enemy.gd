extends CharacterBody2D
class_name Player

signal died

@export var ACCELERATION = 500
@export var MAX_SPEED = 100
@export var FRICTION = 500

enum State {
	MOVE
}

var player: PlayerController
var state: State = State.MOVE
var scratch_velocity: Vector2 = Vector2.ZERO
#var stats = PlayerStats


# initialize as if it was being initialized in _ready
#@onready var animationTree = $AnimationTree
#@onready var animationState = animationTree.get("parameters/playback")
#@onready var hurtbox = $Hurtbox
#@onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
#	stats.connect("no_health", Callable(self, "_on_Stats_no_health"))
	reset()

func reset():
	state = State.MOVE
	var players = get_tree().get_nodes_in_group(&"PlayerGroup")
	if players.size() != 1:
		push_error("Found Non-1 number of players!")
		return
	player = players[0]
	
#	animationTree.active = true
	
	scratch_velocity = Vector2.ZERO

#	stats.reset()

# Update
func _physics_process(delta):
	match state:
		State.MOVE:
			move_state(delta)
	
func move_state(delta):
	var input_vector = (player.global_position - global_position).normalized()
	
	if input_vector != Vector2.ZERO:
		scratch_velocity = scratch_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		scratch_velocity = scratch_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()

func move():
	set_velocity(scratch_velocity)
	move_and_slide()
	scratch_velocity = velocity

#func _on_Stats_no_health():
#	emit_signal("died")

#func _on_Hurtbox_area_entered(area):
#	if area is HitBox && !hurtbox.invincible:
#		got_hit(area.damage)
#
#func got_hit(damage):
#	stats.health -= damage
#	hurtbox.start_invincibility(0.6)
#	_invincibility_started()
#	hurtbox.create_hit_effect()
#	var playerHurtSound = PlayerHurtSound.instantiate()
#	get_tree().current_scene.add_child(playerHurtSound)

#func _on_Hurtbox_body_entered(body):
#	if body is RockWallTileMap && !hurtbox.invincible:
#		var result = Utils.shape_cast_get_result(hurtbox.collisionShape.shape, hurtbox.collisionShape.global_transform)
#		if result == null || result.is_empty():
#			return
#		else:
#			for res in result:
#				body.delete_cell(res["metadata"][0], res["metadata"][1])
#
#		got_hit(body.damage)
	
