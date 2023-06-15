extends CanvasLayer
class_name UIController

@export var game_over: PackedScene = preload("res://Scenes/GameOver.tscn")

@onready var wave_label: Label = $WaveLabel
@onready var energy_label: Label = $HBoxContainer/EnergyLabel
@onready var game_scene: GameController = $SubViewportContainer/SubViewport/TestScene
@onready var tutorial_label: Label = $TutorialText

var tutorial_state: TutorialState = TutorialState.COMPLETE

func _ready():
	if !SceneUtil.tutorial_completed:
		tutorial_state = TutorialState.MOVE
		tutorial_label.visible = true
		tutorial_label.text = "WASD To Move"
		
	game_scene.player_moved.connect(on_player_moved)
	game_scene.player_meleed.connect(on_player_melee)
	game_scene.radial_menu_opened.connect(on_radial_open)
	game_scene.trap_placed.connect(on_trap_placed)
	game_scene.wave_started.connect(on_wave_started)
	game_scene.trap_cancelled.connect(on_trap_cancel)

func on_game_lost(wave_number: int, time_elapsed: int):
	game_scene.queue_free()
	var instance = game_over.instantiate()
	add_child(instance)
	instance.init(time_elapsed, wave_number)

func new_wave(wave_number: int):
	wave_label.text = "Wave " + str(wave_number)
	
func on_inventory_updated(inventory: Inventory):
	energy_label.text = "%d" % inventory.energy

enum TutorialState {
	MOVE,
	MELEE,
	OPEN_RADIAL,
	PLACE_TRAP,
	CANCEL_TRAP,
	START_WAVE,
	COMPLETE
}

func on_player_moved():
	if tutorial_state == TutorialState.MOVE:
		tutorial_state = TutorialState.MELEE
		tutorial_label.text = "E To Melee Attack"

func on_player_melee():
	if tutorial_state == TutorialState.MELEE:
		tutorial_state = TutorialState.OPEN_RADIAL
		tutorial_label.text = "Hold SPACE To Select Trap For Placement"

func on_radial_open():
	if tutorial_state == TutorialState.OPEN_RADIAL:
		tutorial_state = TutorialState.PLACE_TRAP
		tutorial_label.text = "Release SPACE To Select Trap. LEFT CLICK To Place."

func on_trap_placed():
	if tutorial_state == TutorialState.PLACE_TRAP:
		tutorial_state = TutorialState.CANCEL_TRAP
		tutorial_label.text = "RIGHT CLICK To Cancel Trap Placement."

func on_trap_cancel():
	if tutorial_state == TutorialState.CANCEL_TRAP:
		tutorial_state = TutorialState.START_WAVE
		tutorial_label.text = "TAB To Start Wave When Ready."

func on_wave_started():
	if tutorial_state == TutorialState.START_WAVE:
		tutorial_state = TutorialState.COMPLETE
		SceneUtil.tutorial_completed = true
		tutorial_label.text = "Protect the Pixel Core. Good luck!"
		var timer = get_tree().create_timer(5.0)
		timer.timeout.connect(on_tutorial_complete)
		

func on_tutorial_complete():
	tutorial_label.queue_free()
