extends Node2D
class_name TrapStandin

@onready var sprite: Sprite2D = $Sprite2D
var id: TrapData.TrapId

func init(_id: TrapData.TrapId):
	id = _id
	sprite.texture = GlobalTrapData.get_ui_icon_for_id(_id)
	sprite.offset = GlobalTrapData.get_ui_icon_placement_offset(_id)
