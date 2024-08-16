class_name Projectile extends RigidBody2D

@export var player: bool = false

func destroy():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	destroy()
