class_name Projectile extends RigidBody2D

@export var player: bool = false

func destroy():
	queue_free()
