extends Node2D

@onready var one_off_prefab = preload("res://Scenes/AudioEffect.tscn")

@onready var trap_sfx = $TrapSFX
@onready var enemy_sfx = $EnemySFX
@onready var gem_sfx = $GemSFX

func play_trap_sfx(stream: AudioStream):
	play_audio_in_group(trap_sfx, stream)
	
func play_audio_in_group(group: Node2D, stream: AudioStream):
	for child in group.get_children():
		if !(child is AudioStreamPlayer):
			continue
		
		if !child.playing:
			child.stream = stream
			child.play()

func play_enemy_sfx(stream: AudioStream):
	play_audio_in_group(enemy_sfx, stream)
	
func play_gem_sfx(stream: AudioStream):
#	play_audio_in_group(gem_sfx, stream)
	pass

func play_one_off(stream: AudioStream):
	var fx = one_off_prefab.instantiate()
	get_tree().root.add_child(fx)
	fx.play_sound(stream)
