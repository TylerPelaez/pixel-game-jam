extends Node2D

@onready var title_music = preload("res://MusicSound/Title_Screen_Music.mp3")
@onready var gameplay_music = preload("res://MusicSound/Sentient_Crisis_Gameplay_Music.mp3")

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func play_title_music():
	audio_player.stream = title_music
	audio_player.play()

func start_gameplay_music():
	audio_player.volume_db = -16
	audio_player.stream = gameplay_music
	audio_player.play()
	var tween = get_tree().create_tween()
	tween.tween_property(audio_player, "volume_db", 0, 1.0).set_trans(Tween.TRANS_LINEAR)

func fade_gameplay_music():
	var tween = get_tree().create_tween()
	tween.tween_property(audio_player, "volume_db", -16, 1.0).set_trans(Tween.TRANS_LINEAR)

func dim_game_music_for_wave_complete():
	start_gameplay_music()

func stop():
	audio_player.stop()
