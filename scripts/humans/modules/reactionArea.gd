# -- reactionArea.gd -- #
# |- Area2D
# |- |- CollisionShape2D
# |- Node2D (visual target position) (optional)
# |- |- Node2D (1 target)
# |- |- Node2D (2 target)
# |- |- ... (3-99 target)
extends Node2D

export(String) var reactTo = "zombie"
export(Array) var reactTargetQueue = []
export(NodePath) var targetPositionVisualPath

onready var area = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var host: Node2D = $".."
onready var targetPositionVisual: Node2D = get_node_or_null(targetPositionVisualPath)


func _ready():
	if targetPositionVisual:
		for i in targetPositionVisual.get_children():
			reactTargetQueue.append(i.global_position)
			i.queue_free()
	
	host.target_queue = reactTargetQueue.duplicate()
	if host.has_signal("endTurn"): host.connect("endTurn", self, "_host_end_turn")
	area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node2D):
	if body.is_in_group(reactTo) && host != body:
		if host.has_method("start_movement"):
			host.start_movement()
			area.monitoring = false

func _host_end_turn():
	area.monitoring = true
