extends Node2D

signal collected(amount: int)


@onready var sfx_1: AudioStream = preload("res://MusicSound/Gem_Pickup_1.mp3")
@onready var sfx_2: AudioStream = preload("res://MusicSound/Gem_Pickup_2.mp3")
@onready var sfx_3: AudioStream = preload("res://MusicSound/Gem_Pickup_3.mp3")

@onready var sprite: Sprite2D = $Sprite2D
var amount: int = 10

var being_sucked: bool = false
var suck_target: Node2D
var suck_speed: float = 100.0

var suck_complete_distance: float = 5

func _ready():
	var timer = get_tree().create_timer(25.0)
	timer.timeout.connect(on_blink_start_timer_complete)

func on_blink_start_timer_complete():
	$Blink.play("Blink")
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(queue_free)
	
func _process(delta):
	if being_sucked:
		var to_target = global_position.direction_to(suck_target.global_position)
		global_position += to_target * suck_speed * delta
		if global_position.distance_to(suck_target.global_position) < suck_complete_distance:
			var rand = randf()
			var stream
			if rand < 0.33:
				stream = sfx_1
			elif rand < 0.66:
				stream = sfx_2
			else:
				stream = sfx_3
			
			SfxController.play_gem_sfx(stream)
			
			collected.emit(amount)
			queue_free()
	

func set_flipped(value: bool):
	sprite.flip_h = value

func _on_area_2d_area_entered(area):
	being_sucked = true
	suck_target = area


func _on_area_2d_area_exited(area):
	being_sucked = false
