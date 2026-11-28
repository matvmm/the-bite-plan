# -- plan_point.gd -- #
extends Sprite

onready var tween = $Tween


func _ready():
	add_to_group("plan point")

func create_point(pos: Vector2, zombie_id: int):
	set_meta("zombie_id", zombie_id)
	global_position = pos
	
	tween.interpolate_property(self, "scale", Vector2.ONE*1.2, Vector2.ONE, 0.1, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate:a", 0.0, 1.0, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()

func remove_point():
	tween.interpolate_property(self, "scale", Vector2.ONE, Vector2.ONE*1.5, 0.1, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.1, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	queue_free()
