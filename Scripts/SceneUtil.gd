extends Node

@onready var game_scene: PackedScene = preload("res://Scenes/ui_controller.tscn")
@onready var main_menu_scene: PackedScene = preload("res://Scenes/Title Screen.tscn")

var game_world_viewport: SubViewport

var tutorial_completed: bool = true

func start_game():
	get_tree().change_scene_to_packed(game_scene)
	
func load_main_menu():
	get_tree().change_scene_to_packed(main_menu_scene)
