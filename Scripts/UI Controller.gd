extends CanvasLayer
class_name UIController

@onready var wave_label: Label = $WaveLabel

@export var trap_box_prefab: PackedScene
@export var trap_box_container: HBoxContainer

@export var energy_label: Label

var trap_id_to_box = {}

func _ready():
	for trap_id in TrapData.TrapId:
		var id = TrapData.TrapId.get(trap_id)
		var trap_box = trap_box_prefab.instantiate()
		trap_id_to_box[id] = trap_box
		trap_box_container.add_child(trap_box)
		trap_box.texture = GlobalTrapData.get_ui_icon_for_id(id)

func new_wave(wave_number):
	wave_label.text = "Wave " + str(wave_number)

func on_inventory_updated(inventory: Inventory):
	for trap_id in trap_id_to_box.keys():
		trap_id_to_box[trap_id].set_count(inventory.get_count(trap_id))
	
	energy_label.text = "$%d" % inventory.energy
	
