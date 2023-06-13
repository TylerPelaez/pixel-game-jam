extends Node
class_name TrapData

enum TrapId {
	Melee,
	Barricade,
	AOE,
	Laser,
	Knockback
}

var db = {
	TrapId.Melee: {
		"stand_in": preload("res://Player/Traps/MeleeTrapStandin.tscn"),
		"trap": preload("res://Player/Traps/MeleeTrap.tscn"),
		"ui_icon": preload("res://Textures/Test/White32.png")
	},
	TrapId.Barricade: {
		"stand_in": preload("res://Player/Traps/TrapStandin.tscn"),
		"trap": preload("res://Player/Traps/Trap.tscn"),
		"ui_icon": preload("res://Textures/Test/White32.png")
	},
	TrapId.AOE: {
		"stand_in": preload("res://Player/Traps/aoe_trap_standin.tscn"),
		"trap": preload("res://Player/Traps/aoe_trap.tscn"),
		"ui_icon": preload("res://Textures/Test/White32.png")
	},
	TrapId.Laser: {
		"stand_in": preload("res://Player/Traps/aoe_trap_standin.tscn"),
		"trap": preload("res://Player/Traps/aoe_trap.tscn"),
		"ui_icon": preload("res://Textures/Test/White32.png")
	},
	TrapId.Knockback: {
		"stand_in": preload("res://Player/Traps/TrapStandin.tscn"),
		"trap": preload("res://Player/Traps/Trap.tscn"),
		"ui_icon": preload("res://Textures/Test/White32.png")
	}
}

func get_trap_for_id(id: TrapId):
	return db[id]["trap"]

func get_stand_in_for_id(id: TrapId):
	return db[id]["stand_in"]

func get_ui_icon_for_id(id: TrapId):
	return db[id]["ui_icon"]
