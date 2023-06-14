extends Node
class_name Inventory

signal updated(inventory: Inventory)

var trap_inventory := {}
var energy := 0 : set = _set_energy

func _ready():
	energy = 200

func add_trap(trap_id: TrapData.TrapId, count: int):
	if !trap_inventory.has(trap_id):
		trap_inventory[trap_id] = count
	else:
		trap_inventory[trap_id] += count
	updated.emit(self)

func remove_trap(trap_id: TrapData.TrapId, count: int):
	trap_inventory[trap_id] -= count
	updated.emit(self)

func has_trap_count(trap_id: TrapData.TrapId, count: int):
	return trap_inventory.has(trap_id) && trap_inventory[trap_id] >= count

func get_count(trap_id: TrapData.TrapId):
	return trap_inventory[trap_id] if trap_inventory.has(trap_id) else 0

func _set_energy(amount: int):
	energy = amount
	updated.emit(self)

func can_afford(id: TrapData.TrapId):
	return energy > GlobalTrapData.get_cost(id)
