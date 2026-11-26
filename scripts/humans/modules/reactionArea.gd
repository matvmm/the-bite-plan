# -- reactionArea.gd -- #
# |- Area2D
# |- |- CollisionShape2D
# |- Node2D (visual target position) (optional)
extends Node2D

export(String) var reactTo = "zombie"
export(Vector2) var reactTargetPosition = Vector2.ZERO
export(NodePath) var targetPositionVisualPath

onready var area = $Area2D
onready var collision_shape = $Area2D/CollisionShape2D
onready var host: Node2D = $".."
onready var targetPositionVisual: Node2D = get_node_or_null(targetPositionVisualPath)


func _ready():
	if targetPositionVisual: reactTargetPosition = targetPositionVisual.global_position
	
	area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node2D):
	if body.is_in_group(reactTo) && host != body:
		if host.has_method("set_target"): host.set_target(reactTargetPosition)
