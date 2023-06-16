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

var cur_energy_count: int = 0

func _ready():
	var i = 0
	for trap_id in TrapData.TrapId:
		var id = TrapData.TrapId.get(trap_id)
		fill_order[i].set_trap(id)
		i += 1


func _process(delta):
	indicator.rotation = Vector2.ZERO.angle_to_point(current_radial_pos)

func energy_count_updated(new_amount):
	cur_energy_count = new_amount
	update_colors()

func set_open(value: bool):
	current_radial_pos = Vector2.ZERO
	visible = value
	(opened if visible else closed).emit()
	
	update_colors()

func _input(event):
	if !visible:
		return
	if event is InputEventMouseMotion:
		current_radial_pos += event.relative
	
	update_colors()


func update_colors():
	var max_dot = -9999
	var highlighted_box = right_box
	
	if current_radial_pos != Vector2.ZERO:
		for box in fill_order:
			var direction = (box.global_position - global_position).normalized()
			var d = current_radial_pos.normalized().dot(direction)
			box.set_highlight(false)
			if d > max_dot:
				max_dot = d
				highlighted_box = box
		
	name_label.text = GlobalTrapData.get_name_for_trap(highlighted_box.trap_id)
	cost_label.text = str(GlobalTrapData.get_cost(highlighted_box.trap_id))
	cost_label.add_theme_color_override("font_color", Color.WHITE)
	current_selection = highlighted_box
	
	var i = 0
	for trap_id in TrapData.TrapId:
		var id = TrapData.TrapId.get(trap_id)
		fill_order[i].set_unpurchaseable(GlobalTrapData.get_cost(id) > cur_energy_count)
		if fill_order[i] == highlighted_box and GlobalTrapData.get_cost(id) > cur_energy_count:
			cost_label.add_theme_color_override("font_color", Color.RED)
		if GlobalTrapData.get_cost(id) <= cur_energy_count and fill_order[i] == highlighted_box:
			highlighted_box.set_highlight(true)
		
		i += 1
	
func get_currently_selected_trap():
	return null if current_selection == null else current_selection.trap_id
