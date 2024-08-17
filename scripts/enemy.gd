class_name Enemy extends Area2D

signal destroyed_by_player(size: int)

@export var size: int = 1
@export var hp: int = 1

var wander_time: float = 0.0
var wander_vec: Vector2i = Vector2i(0.0, 0.0)

func _ready():
	connect("body_entered", _on_enemy_body_entered)

func _process(delta):
	wander_time -= delta
	if wander_time < 0.0:
		wander_time = 5.0
		var angle = randi() % 360
		wander_vec.x = cos(angle) * 10
		wander_vec.y = sin(angle) * 10
	position += wander_vec * delta

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
