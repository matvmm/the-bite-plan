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
	if !has_target || !target_queue.size() > 0: return
	
	if target_queue.size()-1 >= current_queue_num:
		target_position = target_queue[current_queue_num]
	else:
		has_target = false
		print("I finished :) .")
		reset_movement()
		return
	
	var dir: Vector2 = (target_position - global_position).normalized()
	var vel: Vector2 = dir * speed * delta
	
	vel = move_and_slide(vel)
	
	sprite.flip_h = true if vel.x < 0.0 else false
	
	if is_on_wall():
		has_target = false
		reset_target_queue()
		print("Zombie " + self.name + "says: 'I DONT KNOW HOW TO WALK AROUND THE WALL!!!!!!! >:('.")
		return
	
	# position = position.move_toward(target_position, speed * delta)
	
	if global_position.distance_to(target_position) < 2.0:
		current_queue_num += 1
		# has_target = false

#func _unhandled_input(event):
#	if event.is_action_pressed("ui_accept"):
#		start_movement()
#	if !selected: return
#	if event.is_action_pressed("SET_POINT"):
#		add_target(get_global_mouse_position())

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		start_movement()
		return
	if !selected: return
	if not event.is_action_pressed("SET_POINT"): return
	
	var hits = get_world_2d().direct_space_state.intersect_point(get_global_mouse_position())
	for i in hits:
		if i.collider.is_in_group("zombie"):
			return
	
	add_target(get_global_mouse_position())

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
	if plan_points: plan_points.remove_lines()
	current_queue_num = 0
	global_position = start_position

func start_movement():
	if !target_queue.size() > 0: return
	has_target = true

func add_target(new_target: Vector2):
	target_queue.append(new_target)
	
	if plan_points:
		var plan_point: Sprite = load(planPointScenePath).instance()
		plan_points.add_child(plan_point)
		var linearray: Array = target_queue
		linearray.insert(0, start_position)
		plan_points.add_lines(linearray)
		plan_point.create_point(new_target)
	
	print("Added new target point: " + str(new_target))

func remove_target(target: Vector2):
	target_queue.remove(target_queue.find(target))
	for i in get_tree().get_nodes_in_group("plan point"):
		if i.global_position == target: i.queue_free()
	plan_points.line.points.remove(plan_points.line.points.find(target))
	
	print("Removed target point: " + str(target))

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.is_action("SET_POINT"):
		get_tree().set_input_as_handled()
		if selected: unselect()
		else: select()

func select():
	selected = true
	sprite.modulate.b = 0.5
	for i in get_tree().get_nodes_in_group("zombie"):
		if i != self: i.unselect()

func unselect():
	selected = false
	sprite.modulate.b = 1.0
#	if target_queue.size() > 0: remove_target(target_queue[target_queue.size()-1])
