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
	modulate.a = 0.5 if unpurchaseable else 1.0
	modulate.g = 0 if unpurchaseable else 1.0
	modulate.b = 0 if unpurchaseable else 1.0 

func set_highlight(highlight: bool):
	modulate.r = 0 if highlight else 1
	modulate.g = 1
	modulate.b = 0 if highlight else 1
