extends Control
class_name RadialMenu

signal opened
signal closed

@onready var top_box: UITrapBox = $TopBox
@onready var right_box: UITrapBox = $RightBox

@onready var left_box: UITrapBox = $LeftBox
@onready var fill_order := [left_box, top_box, right_box]
@onready var indicator: Sprite2D = $Indicator

@onready var name_label: Label = $InfoBox/VBoxContainer/Name
@onready var cost_label: Label = $InfoBox/VBoxContainer/HBoxContainer/Cost

var current_radial_pos := Vector2.ZERO
var current_selection : UITrapBox  

func _ready():
	var i = 0
	for trap_id in TrapData.TrapId:
		var id = TrapData.TrapId.get(trap_id)
		fill_order[i].set_trap(id)
		i += 1


func _process(delta):
	indicator.rotation = Vector2.ZERO.angle_to_point(current_radial_pos)

func energy_count_updated(new_amount):
	var i = 0
	for trap_id in TrapData.TrapId:
		var id = TrapData.TrapId.get(trap_id)
		fill_order[i].set_unpurchaseable(GlobalTrapData.get_cost(id) > new_amount)
		i += 1

func set_open(value: bool):
	current_radial_pos = Vector2.ZERO
	visible = value
	(opened if visible else closed).emit()

func _input(event):
	if !visible:
		return
	if event is InputEventMouseMotion:
		current_radial_pos.x = clamp(current_radial_pos.x + (event.relative.x / 20.0), -1, 1)
		current_radial_pos.y = clamp(current_radial_pos.y + (event.relative.y / 20.0), -1, 1)
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
	name_label.text = GlobalTrapData.get_name_for_trap(highlighted_box.trap_id)
	cost_label.text = str(GlobalTrapData.get_cost(highlighted_box.trap_id))
	current_selection = highlighted_box
	
func get_currently_selected_trap():
	return null if current_selection == null else current_selection.trap_id
