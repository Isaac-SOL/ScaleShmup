class_name PlayerPart extends Area2D

var direction: Vector2 = Vector2.ZERO

func _process(delta):
	position += direction * delta
