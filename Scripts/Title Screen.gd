extends Control

@onready var game_scene: PackedScene = preload("res://Scenes/ui_controller.tscn")

@onready var star_holder: StarHolder = $SubViewportContainer/SubViewport/StarHolder
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var title_label

var scrolling_to_main_menu: bool = false
var scroll_complete: bool = false

var showing_backstory: bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	MusicController.play_title_music()

func _input(event):
	if event.is_pressed() && !scrolling_to_main_menu && !scroll_complete:
		move_to_main_menu()

func _process(delta):
	if Input.is_anything_pressed() && showing_backstory:
		animation_player.speed_scale = 6
	elif showing_backstory:
		animation_player.speed_scale = 1
		
func move_to_main_menu():
	scrolling_to_main_menu = true
	animation_player.play("Scroll")

func start_cam_scroll():
	star_holder.scroll_camera_down(3.0, Tween.EASE_IN_OUT)

func _on_scroll_complete():
	scrolling_to_main_menu = false
	scroll_complete = true

func _on_play_pressed():
	if !showing_backstory:
		showing_backstory = true
		animation_player.play("ShowBackstory")

func _on_credits_pressed():
	if !showing_backstory:
		animation_player.play("Show Credits")

func _on_quit_pressed():
	if !showing_backstory:
		get_tree().quit()

func _on_credits_back_pressed():
	if !showing_backstory:
		animation_player.play("Hide Credits")
	
func _on_backstory_complete():
	get_tree().change_scene_to_packed(game_scene)
