extends CanvasLayer
class_name UIController

@onready var wave_label: Label = $WaveLabel
@export var energy_label: Label

func new_wave(wave_number):
	wave_label.text = "Wave " + str(wave_number)

func on_inventory_updated(inventory: Inventory):
	energy_label.text = "$%d" % inventory.energy
