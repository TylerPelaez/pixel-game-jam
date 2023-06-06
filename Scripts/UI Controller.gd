extends CanvasLayer
class_name UIController

@onready var wave_label: Label = $WaveLabel

func new_wave(wave_number):
	wave_label.text = "Wave " + str(wave_number)
