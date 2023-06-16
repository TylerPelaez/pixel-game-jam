extends AudioStreamPlayer


func play_sound(sfx):
	stop()
	stream = sfx
	play()

func _on_finished():
	queue_free()
