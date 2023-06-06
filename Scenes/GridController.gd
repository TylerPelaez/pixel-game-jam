extends Node2D
class_name GridController

signal placement_started
signal placement_ended
signal placed_trap(trap: Trap)

@export var trap_placement_prefab_1: PackedScene
@export var trap_placement_prefab_2: PackedScene
@export var GRID_SIZE_PIXELS: int = 16

@export var GRID_DIMENSIONS: Vector2i = Vector2.ZERO

@onready var shape_cast: ShapeCast2D = $ShapeCast2D

enum State {
	DEFAULT,
	PLACING
}

var state: State = State.DEFAULT
var trap_placement_instance: Node2D

func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / GRID_SIZE_PIXELS) * GRID_SIZE_PIXELS,  floor(pos.y / GRID_SIZE_PIXELS) * GRID_SIZE_PIXELS) + Vector2(GRID_SIZE_PIXELS / 2, GRID_SIZE_PIXELS / 2)

func world_pos_to_grid_coords(pos: Vector2) -> Vector2i:
	return ((GRID_DIMENSIONS * GRID_SIZE_PIXELS / 2.0) + snap_to_grid(pos)) / GRID_SIZE_PIXELS

func _process(delta):
	match state:
		State.DEFAULT:
			return
		State.PLACING:
			var mouse_pos = get_global_mouse_position()
			var grid_pos = snap_to_grid(mouse_pos)
			trap_placement_instance.global_position = grid_pos
			trap_placement_instance.modulate = Color.WHITE if can_place(trap_placement_instance, grid_pos) else Color.RED

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

func can_place(current_trap: TrapStandin, pos: Vector2):
	if shape_cast.shape is RectangleShape2D:
		shape_cast.shape.size = Vector2(GRID_SIZE_PIXELS + 2, GRID_SIZE_PIXELS + 2)
	else:
		push_error("Wrong Shape in Shape Cast!")
		return false
	
	shape_cast.position = snap_to_grid(pos)
	shape_cast.set_collision_mask_value(1, false)
	shape_cast.set_collision_mask_value(2, true)
	shape_cast.set_collision_mask_value(6, true)
	
	shape_cast.force_shapecast_update()
	var colliding_with_entities = shape_cast.is_colliding()
	
	shape_cast.shape.size = Vector2(GRID_SIZE_PIXELS - 1, GRID_SIZE_PIXELS - 1)
	shape_cast.set_collision_mask_value(1, true)
	shape_cast.set_collision_mask_value(2, false)
	shape_cast.set_collision_mask_value(6, false)
	
	shape_cast.force_shapecast_update()
	var colliding_with_world = shape_cast.is_colliding()
	
	return !colliding_with_entities && !colliding_with_world

func place_trap(current_trap: TrapStandin, pos: Vector2):
	if !can_place(current_trap, pos):
		return
	
	var new_trap = current_trap.real_trap.instantiate()
	get_parent().add_child(new_trap)
	new_trap.position = pos
	placed_trap.emit(new_trap)
	trap_placement_instance.queue_free()
	state = State.DEFAULT
