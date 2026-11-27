# -- base_zombie.gd -- #
extends KinematicBody2D

export(float) var speed = 100.0
export(String) var planPointScenePath = "res://scenes/plan_point.tscn"

var target_position: Vector2 = Vector2.ZERO
var current_queue_num: int = 0
var start_position: Vector2 = Vector2.ZERO
var target_queue: Array = []
var has_target: bool = false


func _ready():
	add_to_group("zombie")
	start_position = global_position

func _physics_process(delta):
	if !has_target || !target_queue.size() > 0: return
	
	if target_queue.size()-1 >= current_queue_num:
		target_position = target_queue[current_queue_num]
	else:
		has_target = false
		print("I finished :) .")
		return
	
	var dir: Vector2 = (target_position - global_position).normalized()
	var vel: Vector2 = dir * speed
	
	vel = move_and_slide(vel)
	
	if is_on_wall():
		has_target = false
		print("Zombie " + self.name + "says: 'I DONT KNOW HOW TO WALK AROUND THE WALL!!!!!!! >:('.")
	
	# position = position.move_toward(target_position, speed * delta)
	
	if position.distance_to(target_position) < 2.0:
		current_queue_num += 1
		# has_target = false

func _input(event):
	if Input.is_key_pressed(KEY_ENTER): start_movement()
	if Input.is_action_just_pressed("SET_POINT"):
		if !has_target:
			add_target(get_global_mouse_position())

func reset_target_queue():
	has_target = false
	target_queue.clear()
	if get_tree().get_nodes_in_group("plan point").size() > 0:
		for i in get_tree().get_nodes_in_group("plan point"):
			i.queue_free()
	current_queue_num = 0
	global_position = start_position

func start_movement():
	has_target = true

func add_target(new_target: Vector2):
	target_queue.append(new_target)
	
	var plan_point: Sprite = load(planPointScenePath).instance()
	get_tree().current_scene.add_child(plan_point)
	plan_point.create_point(new_target)
	
	print("Added new target point: " + str(new_target))
