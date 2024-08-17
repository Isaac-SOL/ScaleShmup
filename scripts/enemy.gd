class_name Enemy extends Area2D

signal destroyed_by_player(size: int)

@export var size: int = 1
@export var hp: int = 1

func _ready():
	connect("body_entered", _on_enemy_body_entered)

func destroy():
	queue_free()

func _on_enemy_body_entered(body: Node2D):
	if body is Projectile and body.player:
		body.destroy()
		hp -= 1
		if hp == 0:
			destroyed_by_player.emit(size)
			destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	destroy()
