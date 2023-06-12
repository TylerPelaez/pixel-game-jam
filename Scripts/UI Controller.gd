extends CanvasLayer
class_name UIController

@onready var wave_label: Label = $WaveLabel

@export var barricade_trap_box: UITrapBox
@export var melee_trap_box: UITrapBox

func _ready():
	barricade_trap_box.texture = GlobalTrapData.get_ui_icon_for_id(TrapData.TrapId.Barricade)
	melee_trap_box.texture = GlobalTrapData.get_ui_icon_for_id(TrapData.TrapId.Melee)

func new_wave(wave_number):
	wave_label.text = "Wave " + str(wave_number)

func on_inventory_updated(inventory: Inventory):
	barricade_trap_box.set_count(inventory.get_count(TrapData.TrapId.Barricade))
	melee_trap_box.set_count(inventory.get_count(TrapData.TrapId.Melee))
