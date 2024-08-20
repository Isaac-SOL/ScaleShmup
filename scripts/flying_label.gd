class_name FlyingLabel extends Node2D

@export var text: String = ""
@export var final_scale: float = 1

func _ready():
	%Label.text = text
	%Label.scale = Vector2.ZERO
	
	var direction: float = randf_range(0.5, 1) * (1 if randf() > 0.5 else -1)
	
	var tween := get_tree().create_tween()
	tween.tween_property(%Label, "scale", Vector2.ONE * final_scale, 0.166).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(%Label, "position", Vector2(-201 + 30 * direction, -32), 0.166).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(%Label, "scale", Vector2.ZERO, 0.333).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(%Label, "position", Vector2(-201 + 60 * direction, 0), 0.333).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
	
	var tween2 := get_tree().create_tween()
	tween2.tween_property(%Label, "rotation", direction * 0.35, 0.5)
