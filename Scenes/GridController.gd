extends Node2D
class_name GridController

signal placement_started
signal placement_ended
signal placed_trap(trap: Trap)

@export var GRID_SIZE_PIXELS: int = 16

@export var GRID_DIMENSIONS: Vector2i = Vector2.ZERO
@export var inventory: Inventory

@export var trap_placement_prefab: PackedScene

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
			var grid_pos = snap_to_grid(trap_placement_instance.global_position)
			trap_placement_instance.modulate = Color.WHITE if can_place(trap_placement_instance, grid_pos) else Color.RED

func _input(event):
	if state == State.PLACING and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			event = make_input_local(event)
			place_trap(trap_placement_instance, snap_to_grid(event.position))
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: 
			finish_placement()
	if state == State.PLACING and event is InputEventMouseMotion:
			event = make_input_local(event)
			var mouse_pos = event.position
			var grid_pos = snap_to_grid(mouse_pos)
			trap_placement_instance.global_position = grid_pos
			trap_placement_instance.modulate = Color.WHITE if can_place(trap_placement_instance, grid_pos) else Color.RED

func start_placing(trap_placement_id: TrapData.TrapId):
	if state == State.PLACING:
		finish_placement()
	
	state = State.PLACING
	trap_placement_instance = trap_placement_prefab.instantiate()
	
	get_parent().add_child.call_deferred(trap_placement_instance)
	trap_placement_instance.call_deferred("init", trap_placement_id)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	placement_started.emit()

func can_place(current_trap: TrapStandin, pos: Vector2):
	if !inventory.can_afford(current_trap.id):
		return false
	
	if shape_cast.shape is RectangleShape2D:
		shape_cast.shape.size = Vector2(GRID_SIZE_PIXELS + 2, GRID_SIZE_PIXELS + 2)
	else:
		push_error("Wrong Shape in Shape Cast!")
		return false
	
	shape_cast.position = snap_to_grid(pos)
	shape_cast.set_collision_mask_value(1, false)
	shape_cast.set_collision_mask_value(2, true)
	shape_cast.set_collision_mask_value(6, true)
	shape_cast.set_collision_mask_value(12, false)
	shape_cast.collide_with_areas = false
	shape_cast.collide_with_bodies = true
	
	shape_cast.force_shapecast_update()
	var colliding_with_entities = shape_cast.is_colliding()
	
	shape_cast.shape.size = Vector2(GRID_SIZE_PIXELS - 1, GRID_SIZE_PIXELS - 1)
	shape_cast.set_collision_mask_value(1, true)
	shape_cast.set_collision_mask_value(2, false)
	shape_cast.set_collision_mask_value(6, false)
	shape_cast.set_collision_mask_value(12, false)
	
	shape_cast.force_shapecast_update()
	var colliding_with_world = shape_cast.is_colliding()
	
	shape_cast.shape.size = Vector2(GRID_SIZE_PIXELS - 1, GRID_SIZE_PIXELS - 1)
	shape_cast.set_collision_mask_value(1, false) # World
	shape_cast.set_collision_mask_value(2, false) # Player
	shape_cast.set_collision_mask_value(6, false) # Enemy
	shape_cast.set_collision_mask_value(12, true) # PlaceableArea
	shape_cast.collide_with_areas = true
	shape_cast.collide_with_bodies = false
	
	shape_cast.force_shapecast_update()
	var in_placeable_area = shape_cast.is_colliding()
	
	return !colliding_with_entities && !colliding_with_world && in_placeable_area

func place_trap(current_trap: TrapStandin, pos: Vector2):
	if !can_place(current_trap, pos):
		return
	
	var new_trap = GlobalTrapData.get_trap_for_id(current_trap.id).instantiate()
	get_parent().add_child(new_trap)
	new_trap.position = pos
	placed_trap.emit(new_trap)
	inventory.energy -= GlobalTrapData.get_cost(current_trap.id)
	
	if !inventory.can_afford(current_trap.id):
		finish_placement()

func finish_placement():
	if state == State.PLACING:
		trap_placement_instance.queue_free()
		state = State.DEFAULT
		placement_ended.emit()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func on_radial_menu_opened():
	if state == State.PLACING:
		finish_placement()
