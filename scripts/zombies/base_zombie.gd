# -- base_zombie.gd -- #
extends KinematicBody2D

export(float) var speed = 100.0
var target_position: Vector2 = Vector2.ZERO
var has_target: bool = false


func _physics_process(delta):
	if has_target:
		var dir: Vector2 = (target_position - global_position).normalized()
		var vel: Vector2 = dir * speed
		
		vel = move_and_slide(vel)
		
		if is_on_wall():
			has_target = false
			print("wall!")
		
		# position = position.move_toward(target_position, speed * delta)
		
		if position.distance_to(target_position) < 2.0:
			has_target = false
			print("here!")
	
	

func _input(event):
	if Input.is_action_pressed("SET_POINT"):
		if !has_target: set_target(get_global_mouse_position())

func set_target(new_target: Vector2):
	target_position = new_target
	has_target = true
