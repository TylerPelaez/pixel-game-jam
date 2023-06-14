extends Node
class_name TrapData

enum TrapId {
	AOE,
	Laser,
	Knockback
}

var db = {
	TrapId.Knockback: {
		"trap": preload("res://Player/Traps/KnockbackTrap.tscn"),
		"ui_icon": preload("res://Textures/Player/Traps/KnockbackIcon.png"),
		"placement_offset": Vector2(0, -12),
		"cost": 10
	},
	TrapId.AOE: {
		"trap": preload("res://Player/Traps/aoe_trap.tscn"),
		"ui_icon": preload("res://Textures/Player/Traps/LandmineIcon.png"),
		"placement_offset": Vector2(0, 4),
		"cost": 10
	},
	TrapId.Laser: {
		"trap": preload("res://Player/Traps/laser_trap.tscn"),
		"ui_icon": preload("res://Textures/Player/Traps/LaserIcon.png"),
		"cost": 20
	}
}

func get_trap_for_id(id: TrapId) -> PackedScene:
	return db[id]["trap"]

func get_ui_icon_for_id(id: TrapId) -> Texture2D:
	return db[id]["ui_icon"]

func get_ui_icon_placement_offset(id: TrapId) -> Vector2:
	return db[id]["placement_offset"] if db[id].has("placement_offset") else Vector2.ZERO

func get_cost(id: TrapId) -> int:
	return db[id]["cost"]
