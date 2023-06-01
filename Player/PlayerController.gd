extends CharacterBody2D
class_name PlayerController

signal died

@export var ACCELERATION = 500
@export var MAX_SPEED = 100
@export var FRICTION = 500

enum State {
	MOVE
}

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
	
#	animationTree.active = true
	
	scratch_velocity = Vector2.ZERO

#	stats.reset()

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
#		animationTree.set("parameters/Idle/blend_position", input_vector)
#		animationTree.set("parameters/Run/blend_position", input_vector)
#		animationTree.set("parameters/Attack/blend_position", input_vector)
#		animationTree.set("parameters/Roll/blend_position", input_vector)
#		animationState.travel("Run")

		scratch_velocity = scratch_velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
#		animationState.travel("Idle")
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

#func _invincibility_started():
#	blinkAnimationPlayer.play("Start")

#func pickup_health():
#	$ItemPickupPlayer.stream = PickupHealthSound
#	$ItemPickupPlayer.play()
#
#func pickup_shard():
#	$ItemPickupPlayer.stream = PickupGemSound
#	$ItemPickupPlayer.play()

#func _on_Hurtbox_invincibility_ended():
#	blinkAnimationPlayer.play("Stop")


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
	
