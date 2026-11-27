extends Sprite

onready var tween = $Tween


func _ready():
	add_to_group("plan point")

func create_point(pos: Vector2):
	global_position = pos
	
	tween.interpolate_property(self, "scale", Vector2.ONE*1.2, Vector2.ONE, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate:a", 0.0, 1.0, 0.3, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
