extends CanvasLayer
class_name UIController

@onready var wave_label: Label = $SubViewportContainer/SubViewport/WaveLabel
@onready var energy_label: Label = $SubViewportContainer/SubViewport/EnergyLabel

func new_wave(wave_number):
	wave_label.text = "Wave " + str(wave_number)

func on_inventory_updated(inventory: Inventory):
	energy_label.text = "$%d" % inventory.energy
