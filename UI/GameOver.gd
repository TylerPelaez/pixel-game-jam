extends Control

@onready var star_holder: StarHolder = $SubViewportContainer/SubViewport/StarHolder
@onready var rocket_planet: TextureRect = $RocketPlanet
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var time_survived_label: RichTextLabel = $VBoxContainer2/TimeSurvivedLabel
@onready var waves_survived_label: RichTextLabel = $VBoxContainer2/WavesSurvivedLabel

@onready var restart_button := $HBoxContainer/Restart
@onready var main_menu_button := $HBoxContainer/MainMenu

func init(_time: int, _waves_defeated: int):
	var time_string = "%d:%d:%d" % [ (_time / 3600000) , (_time / 60000) % 60, (_time / 1000) % 60]
	
	time_survived_label.text = "Time Survived: %s" % time_string
	waves_survived_label.text = "Waves Survived: %s" % _waves_defeated

func _ready():
	animation_player.play("FadeIn")

func on_fade_in_complete():
	star_holder.scroll_camera_down(3.0)
	animation_player.play("Scroll")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	rocket_planet.texture.current_frame = 0
	rocket_planet.texture.pause = true

func _on_scroll_complete():
	var timer: SceneTreeTimer = get_tree().create_timer(0.5)
	timer.timeout.connect(_on_post_scroll_delay_complete)

func _on_post_scroll_delay_complete():
	rocket_planet.texture.pause = false
	var timer: SceneTreeTimer = get_tree().create_timer(5.0)
	timer.timeout.connect(func(): animation_player.play("ShowText"))

func _on_show_text_complete():
	restart_button.visible = true
	main_menu_button.visible = true

func _on_restart_pressed():
	SceneUtil.start_game()

func _on_main_menu_pressed():
	SceneUtil.load_main_menu()
