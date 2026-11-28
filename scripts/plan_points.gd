# -- plan_points.gd -- #
extends Node2D

var lines: Dictionary = {}
var select_mode: bool = false


func update_line(zombie_id: int, pos_array: Array):
	if !lines.has(zombie_id): create_line(zombie_id)
	
	var pool_array = PoolVector2Array()
	for i in pos_array:
		pool_array.append(i)
	
	lines[zombie_id].points = pool_array

func create_line(zombie_id: int):
	var new_line = Line2D.new()
	new_line.z_index = -2
	new_line.width = 2.0
	new_line.default_color = Color.red
	new_line.antialiased = false
	
	add_child(new_line)
	new_line.set_meta("zombie_id", zombie_id)
	lines[zombie_id] = new_line

func remove_line(zombie_id: int):
	if lines.has(zombie_id):
		lines[zombie_id].queue_free()
		lines.erase(zombie_id)

func clear_all_lines():
	for i in lines.keys():
		lines[i].queue_free()
	lines.clear()

func enable_select_mode(zombie_id: int):
	select_mode = true
	for i in get_children():
		if i.get_meta("zombie_id") == zombie_id: i.modulate.a = 1.3

func disable_select_mode(zombie_id: int):
	select_mode = false
	for i in get_children():
		if i.get_meta("zombie_id") == zombie_id: i.modulate.a = 0.3
