extends Node2D

@onready var title_music = preload("res://MusicSound/Title_Screen_Music.mp3")
@onready var gameplay_music = preload("res://MusicSound/Sentient_Crisis_Gameplay_Music.mp3")

@onready var audio_player = $AudioStreamPlayer

func play_title_music():
	audio_player.stream = title_music
	audio_player.play()

func start_gameplay_music():
	audio_player.stop()
	audio_player.stream = gameplay_music
	audio_player.play()

func dim_game_music_for_wave_complete():
	audio_player.volume_db = -6
	var timer = get_tree().create_timer(3.2)
	timer.timeout.connect(func(): audio_player.volume_db = 0)

func stop():
	audio_player.stop()
