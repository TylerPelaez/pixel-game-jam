extends NavigationRegion2D
class_name NavController

@export var grid_controller: GridController
var new_navigation_polygon: NavigationPolygon = get_navigation_polygon()

var to_draw = []
var outlines = {}
var grid_to_outline = []
var outline_count = 0
var outlines_to_grids = {}

func _ready():
	parse_2d_collisionshapes(self)
	merge_outlines()
	new_navigation_polygon.make_polygons_from_outlines()
	
func parse_2d_collisionshapes(root_node: Node):
	for i in grid_controller.GRID_DIMENSIONS.x:
		var col = []
		for j in grid_controller.GRID_DIMENSIONS.y:
			col.append(-1)
		grid_to_outline.append(col)
	
	for node in root_node.get_children():
		if node.get_child_count() > 0:
			parse_2d_collisionshapes(node)
	
		if node is CollisionPolygon2D:
			var grid_pos = grid_controller.world_pos_to_grid_coords(node.global_position)
			var collisionpolygon_transform: Transform2D = node.get_global_transform()
			var collisionpolygon: PackedVector2Array = node.polygon
			
			var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon
			
			grid_to_outline[grid_pos.x][grid_pos.y] = outline_count
			outlines[outline_count] = new_collision_outline
			if !outlines_to_grids.has(outline_count):
				outlines_to_grids[outline_count] = []
				
			outlines_to_grids[outline_count].append(grid_pos)
			
			outline_count += 1

func merge_outlines():
	for x in grid_to_outline.size():
		for y in grid_to_outline[x].size():
			if grid_to_outline[x][y] == -1:
				continue
			
			var current_outline_key = grid_to_outline[x][y]
			var current_outline = outlines[current_outline_key]
			
			if x < grid_to_outline.size() - 1 && grid_to_outline[x + 1][y] != -1:
				merge(current_outline_key, grid_to_outline[x + 1][y])
			if y < grid_to_outline[x].size() - 1 && grid_to_outline[x][y + 1] != -1:
				merge(current_outline_key, grid_to_outline[x][y + 1])
			if y < grid_to_outline[x].size() - 1 && x < grid_to_outline.size() - 1 && grid_to_outline[x + 1][y + 1] != -1:
				merge(current_outline_key, grid_to_outline[x + 1][y + 1])
			if y < grid_to_outline[x].size() - 1 && x > 0 && grid_to_outline[x - 1][y + 1] != -1:
				merge(current_outline_key, grid_to_outline[x - 1][y + 1])
				
	for outline in outlines.values():
		to_draw.append(outline)
		new_navigation_polygon.add_outline(outline)

#func _draw():
#	for polygon in to_draw:
#		draw_polygon(polygon, PackedColorArray([Color.PURPLE]))

func merge(current_outline_key: int, adjacent_outline_key: int):
	var current_outline = outlines[current_outline_key]
	var adjacent_outline = outlines[adjacent_outline_key]
	var merge_result = Geometry2D.merge_polygons(adjacent_outline, current_outline)
	if merge_result.size() != 1:
		push_error("Merge Result != 1!!")
		return
	
	outlines[current_outline_key] = merge_result[0]
	
	for grid_pos in outlines_to_grids[adjacent_outline_key]:
		grid_to_outline[grid_pos.x][grid_pos.y] = current_outline_key
		outlines_to_grids[current_outline_key].append(grid_pos)
	
	outlines.erase(adjacent_outline_key)
	outlines_to_grids.erase(adjacent_outline_key)
	
