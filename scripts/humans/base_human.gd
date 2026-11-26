extends KinematicBody2D

export(float) var speed = 150.0
var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false


func _ready():
	add_to_group("human")

func _process(delta):
	if has_target:
		var dir: Vector2 = (target_position - global_position).normalized()
		var vel: Vector2 = dir * speed
		
		vel = move_and_slide(vel)
		
		if is_on_wall():
			has_target = false
		
		if position.distance_to(target_position) < 2.0:
			has_target = false

func set_target(new_target: Vector2):
	target_position = new_target
	has_target = true
