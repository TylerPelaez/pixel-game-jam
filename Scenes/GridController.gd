extends Node2D

@export var trap_placement_prefab_1: PackedScene
@export var trap_placement_prefab_2: PackedScene
@export var GRID_SIZE_PIXELS: int = 8

enum State {
	DEFAULT,
	PLACING
}

var state: State = State.DEFAULT
var trap_placement_instance: Node2D

func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / GRID_SIZE_PIXELS) * GRID_SIZE_PIXELS,  floor(pos.y / GRID_SIZE_PIXELS) * GRID_SIZE_PIXELS) + Vector2(GRID_SIZE_PIXELS / 2, GRID_SIZE_PIXELS / 2)

func _process(delta):
	match state:
		State.DEFAULT:
			return
		State.PLACING:
			var mouse_pos = get_global_mouse_position()
			trap_placement_instance.global_position = snap_to_grid(mouse_pos)

func _input(event):
	if state == State.DEFAULT and event.is_action_pressed("Place Trap 1"):
		start_placing(trap_placement_prefab_1)
	elif state == State.DEFAULT and event.is_action_pressed("Place Trap 2"):
		start_placing(trap_placement_prefab_2)
	
	if state == State.PLACING and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			place_trap(trap_placement_instance, snap_to_grid(get_global_mouse_position()))

func start_placing(trap_placement_prefab: PackedScene):
	state = State.PLACING
	trap_placement_instance = trap_placement_prefab.instantiate()
	get_tree().root.add_child.call_deferred(trap_placement_instance)

func place_trap(current_trap: TrapStandin, pos):
	var new_trap = current_trap.real_trap.instantiate()
	get_tree().root.add_child(new_trap)
	new_trap.position = pos
	state = State.DEFAULT
