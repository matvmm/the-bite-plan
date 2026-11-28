# -- human.gd -- #
extends KinematicBody2D

export(float) var speed = 5000.0

var target_position: Vector2 = Vector2.ZERO
var current_queue_num: int = 0
var start_position: Vector2 = Vector2.ZERO
var target_queue: Array = []
var has_target: bool = false

onready var sprite = $Sprite

signal endTurn


func _ready():
	add_to_group("human")
	start_position = global_position

func _physics_process(delta):
	if !has_target || !target_queue.size() > 0: return
	
	if target_queue.size()-1 >= current_queue_num:
		target_position = target_queue[current_queue_num]
	else:
		has_target = false
		reset_target_queue()
		emit_signal("endTurn")
		return
	
	var dir: Vector2 = (target_position - global_position).normalized()
	var vel: Vector2 = dir * speed * delta
	
	vel = move_and_slide(vel)
	
	sprite.flip_h = true if vel.x < 0.0 else false
	
	if is_on_wall():
		has_target = false
	
	# position = position.move_toward(target_position, speed * delta)
	
	if global_position.distance_to(target_position) < 2.0:
		current_queue_num += 1
		# has_target = false

func reset_target_queue():
	has_target = false
	current_queue_num = 0
	global_position = start_position

func start_movement():
	if !target_queue.size() > 0: return
	has_target = true

func add_target(new_target: Vector2):
	target_queue.append(new_target)
