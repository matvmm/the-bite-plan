# -- base_zombie.gd -- #
extends KinematicBody2D

export(float) var speed = 3500.0
export(String) var planPointScenePath = "res://scenes/plan_point.tscn"

var target_position: Vector2 = Vector2.ZERO
var current_queue_num: int = 0
var start_position: Vector2 = Vector2.ZERO
var target_queue: Array = []
var has_target: bool = false
var selected: bool = false

onready var sprite = $Sprite

onready var plan_points: Node2D = get_tree().current_scene.get_node_or_null("plan_points")


func _ready():
	add_to_group("zombie")
	start_position = global_position

func _physics_process(delta):
	if !has_target || target_queue.size() == 0: return
	
	if target_queue.size()-1 >= current_queue_num:
		target_position = target_queue[current_queue_num]
	else:
		print("I finished :) .")
		reset_movement()
		return
	
	var dir: Vector2 = (target_position - global_position).normalized()
	var vel: Vector2 = dir * speed * delta
	
	vel = move_and_slide(vel)
	
	sprite.flip_h = true if vel.x < 0.0 else false
	
	if is_on_wall():
		reset_movement()
		print("Zombie " + self.name + "says: 'I DONT KNOW HOW TO WALK AROUND THE WALL!!!!!!! >:('.")
		return
	
	# position = position.move_toward(target_position, speed * delta)
	
	if global_position.distance_to(target_position) < 2.0:
		current_queue_num += 1
		# has_target = false

func _unhandled_input(event):
	if event.is_action("ui_accept"):
		start_movement()
		return
	
	if !event is InputEventMouseButton || !event.pressed: return
	
	if sprite.get_rect().has_point(sprite.to_local(get_global_mouse_position())):
		if event.is_action("SET_POINT"):
			get_tree().set_input_as_handled()
			if selected: unselect()
			else: select()
			return
	
	if selected && event.is_action("SET_POINT"):
		for i in get_world_2d().direct_space_state.intersect_point(get_global_mouse_position()):
			if i.collider.is_in_group("zombie"): return
		
		for point in get_tree().get_nodes_in_group("plan point"):
			var local_pos = point.to_local(get_global_mouse_position())
			if point.get_rect().has_point(local_pos):
				if remove_target(point.global_position): return
		
		add_target(get_global_mouse_position())
		get_tree().set_input_as_handled()

func reset_movement():
	has_target = false
	current_queue_num = 0
	global_position = start_position

func reset_target_queue():
	has_target = false
	target_queue.clear()
	if get_tree().get_nodes_in_group("plan point").size() > 0:
		for i in get_tree().get_nodes_in_group("plan point"):
			i.queue_free()
	if plan_points: plan_points.remove_line(get_instance_id())
	current_queue_num = 0
	global_position = start_position

func start_movement():
	if !target_queue.size() > 0: return
	unselect()
	has_target = true

func add_target(new_target: Vector2):
	target_queue.append(new_target)
	
	if plan_points:
		var plan_point: Sprite = load(planPointScenePath).instance()
		plan_points.add_child(plan_point)
		var linearray: Array = target_queue.duplicate()
		linearray.insert(0, start_position)
		plan_points.update_line(get_instance_id(), linearray)
		plan_point.create_point(new_target, get_instance_id())
	
	print("Added new target point: " + str(new_target))

func remove_target(target: Vector2):
	target_queue.erase(target)
	var s: bool = false
	for i in get_tree().get_nodes_in_group("plan point"):
		if i.global_position == target:
			if i.get_meta("zombie_id") == get_instance_id():
				i.remove_point()
				s = true
#	if plan_points && plan_points.line: plan_points.line.points.erase(target)
	if plan_points:
		if target_queue.size() > 0:
			var linearray: Array = target_queue.duplicate()
			linearray.insert(0, start_position)
			plan_points.update_line(get_instance_id(), linearray)
		else:
			plan_points.remove_line(get_instance_id())
	
	print("Removed target point: " + str(target))
	return s

func select():
	selected = true
	if plan_points: plan_points.enable_select_mode(get_instance_id())
	sprite.modulate.b = 0.5
	for i in get_tree().get_nodes_in_group("zombie"):
		if i != self: i.unselect()

func unselect():
	selected = false
	if plan_points: plan_points.disable_select_mode(get_instance_id())
	sprite.modulate.b = 1.0
#	if target_queue.size() > 0: remove_target(target_queue[target_queue.size()-1])
