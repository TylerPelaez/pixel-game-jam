extends Node2D
class_name StarHolder

@onready var stars: Node2D = $Stars
@onready var camera: Camera2D = $Camera2D

@onready var init_camera_pos = camera.global_position
@onready var second_camera_pos = Vector2(camera.global_position.x, camera.global_position.y * 2.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	init_stars()

func init_stars():
	for child in stars.get_children():
		if !child is AnimatedSprite2D:
			continue
		if randf() > 0.25:
			child.queue_free()
		var frames: SpriteFrames = child.get_sprite_frames()
		child.speed_scale = randf_range(0.01, .02)
		child.frame = randi_range(0, frames.get_frame_count("default") - 1)
		child.frame_progress = randf()
		child.pause()
		child.play("default")

func scroll_camera_down(duration: float = 1.0):
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", second_camera_pos, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
