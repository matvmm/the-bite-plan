# -- plan_points.gd -- #
extends Node2D

var line: Line2D


func _ready():
	create_line()

func add_lines(posArray: Array):
	line.points = posArray

func remove_lines():
	line.points = PoolVector2Array()

func create_line():
	line = Line2D.new()
	line.z_index = -2
	line.width = 2.0
	line.default_color = Color.red
	line.antialiased = false
	
	add_child(line)
