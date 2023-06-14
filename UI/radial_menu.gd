extends Control
class_name RadialMenu

signal opened
signal closed

@onready var top_box: UITrapBox = $TopBox
@onready var right_box: UITrapBox = $RightBox
@onready var bottom_box: UITrapBox = $BottomBox
@onready var left_box: UITrapBox = $LeftBox
@onready var fill_order := [left_box, top_box, right_box, bottom_box]

var current_radial_pos := Vector2.ZERO
var current_selection : UITrapBox  

func _ready():
	var i = 0
	for trap_id in TrapData.TrapId:
		var id = TrapData.TrapId.get(trap_id)
		fill_order[i].set_trap(id)
		i += 1

func energy_count_updated(new_amount):
	var i = 0
	for trap_id in TrapData.TrapId:
		var id = TrapData.TrapId.get(trap_id)
		fill_order[i].set_unpurchaseable(GlobalTrapData.get_cost(id) > new_amount)
		i += 1

func set_open(value: bool):
	visible = value
	(opened if visible else closed).emit()

func _input(event):
	if !visible:
		return
	if event is InputEventMouseMotion:
		current_radial_pos.x = clamp(current_radial_pos.x + (event.relative.x / 10.0), -1, 1)
		current_radial_pos.y = clamp(current_radial_pos.y + (event.relative.y / 10.0), -1, 1)
		current_radial_pos = current_radial_pos.normalized()
		
	
	var max_dot = -9999
	var highlighted_box
	for box in fill_order:
		var direction = (box.global_position - global_position).normalized()
		var d = current_radial_pos.dot(direction)
		box.set_highlight(false)
		if d > max_dot:
			max_dot = d
			highlighted_box = box
	
	highlighted_box.set_highlight(true)
	current_selection = highlighted_box
	
func get_currently_selected_trap() -> TrapData.TrapId:
	return current_selection.trap_id
