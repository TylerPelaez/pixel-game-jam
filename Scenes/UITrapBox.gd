extends TextureRect
class_name UITrapBox

@onready var cost_label = $CostLabel

var trap_id: TrapData.TrapId

func set_trap(id: TrapData.TrapId):
	trap_id = id
	texture = GlobalTrapData.get_ui_icon_for_id(id)
	set_cost(GlobalTrapData.get_cost(id))

func set_cost(cost: int):
	cost_label.text = str(cost)

#TODO - modulate abuse!
func set_unpurchaseable(unpurchaseable: bool):
	modulate = Color.RED if unpurchaseable else Color.WHITE

func set_highlight(highlight: bool):
	modulate = Color.GREEN if highlight else Color.WHITE
