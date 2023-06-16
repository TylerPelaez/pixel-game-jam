extends Node2D

@export var player: PlayerController
@export var top_left_bound: Node2D
@export var bottom_right_bound: Node2D
@export var offset: Vector2
@onready var follow_mouse_timer: Timer = $ResetTimer

var follow_mouse: bool = false
var menu_open: bool = false


func _process(delta):
	if menu_open:
		return
	var target_pos = get_global_mouse_position() if follow_mouse else (player.global_position + offset)
	var new_pos = target_pos
	if new_pos.x < top_left_bound.global_position.x:
		new_pos.x = top_left_bound.global_position.x
	if new_pos.y < top_left_bound.global_position.y:
		new_pos.y = top_left_bound.global_position.y
	if new_pos.x > bottom_right_bound.global_position.x:
		new_pos.x = bottom_right_bound.global_position.x
	if new_pos.y > bottom_right_bound.global_position.y:
		new_pos.y = bottom_right_bound.global_position.y
	global_position = new_pos


func start_follow_mouse():
	follow_mouse = true
	follow_mouse_timer.stop()

func begin_stop_follow_mouse():
	follow_mouse_timer.start()

func _on_reset_timer_timeout():
	follow_mouse = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
