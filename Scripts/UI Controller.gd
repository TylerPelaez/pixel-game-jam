extends CanvasLayer
class_name UIController

@export var game_over: PackedScene = preload("res://Scenes/GameOver.tscn")

@onready var wave_label: Label = $WaveLabel
@onready var energy_label: Label = $EnergyLabel
@onready var game_scene: GameController = $SubViewportContainer/SubViewport/TestScene


func on_game_lost(wave_number: int, time_elapsed: int):
	game_scene.queue_free()
	var instance = game_over.instantiate()
	add_child(instance)
	instance.init(time_elapsed, wave_number)

func new_wave(wave_number: int):
	wave_label.text = "Wave " + str(wave_number)

func on_inventory_updated(inventory: Inventory):
	energy_label.text = "$%d" % inventory.energy
