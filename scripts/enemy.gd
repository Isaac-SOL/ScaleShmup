class_name Enemy extends Area2D

func _ready():
	connect("body_entered", _on_enemy_body_entered)

func _on_enemy_body_entered(body: Node2D):
	if body is Projectile and body.player:
		body.destroy()
		destroy()

func destroy():
	queue_free()
