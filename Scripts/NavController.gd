extends NavigationRegion2D
class_name NavController

@export var grid_controller: GridController
var original_navigation_polygon: NavigationPolygon = get_navigation_polygon().duplicate()

var to_draw = []
var outlines = {}
var grid_to_outline = []
var outline_count = 0
var outlines_to_grids = {}

func _ready():
	visible = true
	reset()

func reset():
	outlines = {}
	outline_count = 0
	outlines_to_grids = {}
	grid_to_outline = []
	for i in grid_controller.GRID_DIMENSIONS.x:
		var col = []
		for j in grid_controller.GRID_DIMENSIONS.y:
			col.append(-1)
		grid_to_outline.append(col)
	parse_2d_collisionshapes(self)
	rebuild_polygon_from_outlines()

func rebuild_polygon_from_outlines():
	var new_navigation_polygon = original_navigation_polygon.duplicate()
	merge_outlines(new_navigation_polygon)
	new_navigation_polygon.make_polygons_from_outlines()
	var newpoly = original_navigation_polygon.get_vertices()
	set_navigation_polygon(new_navigation_polygon)
	NavigationServer2D.region_set_navigation_polygon(get_region_rid(), navigation_polygon)

func parse_2d_collisionshapes(root_node: Node):
	for node in root_node.get_children():
		if node is Trap and node.is_dying:
			continue
		if node.get_child_count() > 0:
			parse_2d_collisionshapes(node)
	
		if node is CollisionPolygon2D and should_create_outline(node):
			_add_structure(node)

func merge_outlines(navigation_polygon: NavigationPolygon):
	for x in grid_to_outline.size():
		for y in grid_to_outline[x].size():
			if grid_to_outline[x][y] == -1:
				continue
			
			var current_outline_key = grid_to_outline[x][y]
			var current_outline = outlines[current_outline_key]
			
			if x < grid_to_outline.size() - 1 && grid_to_outline[x + 1][y] != -1 && grid_to_outline[x + 1][y] != current_outline_key:
				merge(current_outline_key, grid_to_outline[x + 1][y])
			if y < grid_to_outline[x].size() - 1 && grid_to_outline[x][y + 1] != -1 && grid_to_outline[x][y + 1] != current_outline_key:
				merge(current_outline_key, grid_to_outline[x][y + 1])
			if y < grid_to_outline[x].size() - 1 && x < grid_to_outline.size() - 1 && grid_to_outline[x + 1][y + 1] != -1 && grid_to_outline[x + 1][y + 1] != current_outline_key:
				merge(current_outline_key, grid_to_outline[x + 1][y + 1])
			if y < grid_to_outline[x].size() - 1 && x > 0 && grid_to_outline[x - 1][y + 1] != -1 && grid_to_outline[x - 1][y + 1] != current_outline_key:
				merge(current_outline_key, grid_to_outline[x - 1][y + 1])
				
	for outline in outlines.values():
		to_draw.append(outline)
		navigation_polygon.add_outline(outline)

#func _draw():
#	for polygon in to_draw:
#		draw_polygon(polygon, PackedColorArray([Color.PURPLE]))

func merge(current_outline_key: int, adjacent_outline_key: int):
	var current_outline = outlines[current_outline_key]
	var adjacent_outline = outlines[adjacent_outline_key]
	var merge_result = Geometry2D.merge_polygons(adjacent_outline, current_outline)
	outlines[current_outline_key] = merge_result[0]
	
	for grid_pos in outlines_to_grids[adjacent_outline_key]:
		grid_to_outline[grid_pos.x][grid_pos.y] = current_outline_key
		outlines_to_grids[current_outline_key].append(grid_pos)
	
	outlines.erase(adjacent_outline_key)
	outlines_to_grids.erase(adjacent_outline_key)

func should_create_outline(collider: CollisionPolygon2D):
	return !collider.disabled and collider.is_in_group("ImpedesNavigation")

func _add_structure(collider: CollisionPolygon2D):
	if !should_create_outline(collider) || !(collider is NavGridImpediment):
		return	

	var collisionpolygon_transform: Transform2D = collider.get_global_transform()
	var collisionpolygon: PackedVector2Array = collider.polygon
	
	var grid_pos = grid_controller.world_pos_to_grid_coords(collider.global_position)
	var grid_positions = []
	for slot_offset in collider.slots_taken_up:
		grid_positions.append(grid_pos + slot_offset)
	
	var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon
	outlines[outline_count] = new_collision_outline
	
	for pos in grid_positions:
		grid_to_outline[pos.x][pos.y] = outline_count

		if !outlines_to_grids.has(outline_count):
			outlines_to_grids[outline_count] = []
			
		outlines_to_grids[outline_count].append(pos)
	outline_count += 1
	
	
func add_structure(node: Trap, collider: CollisionPolygon2D):
	node.get_parent().remove_child(node)
	add_child(node)
	var grid_pos = grid_controller.world_pos_to_grid_coords(collider.global_position)
	if grid_to_outline[grid_pos.x][grid_pos.y] != -1:
		push_error("Attempting to place structure on existing structure!")
		return
	
	node.on_death.connect(destroy_structure, Object.ConnectFlags.CONNECT_DEFERRED)
	
	# Add the outline, then we're just gonna rebuild our whole thing
	_add_structure(collider)
	# If this becomes very slow, then do this smarter. For now though, sue me I'm gonna rebuild it all!
	rebuild_polygon_from_outlines()

func destroy_structure():
	reset() # Too hard to figure out rn
