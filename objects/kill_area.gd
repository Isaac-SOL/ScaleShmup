class_name KillArea extends Area2D

func set_kill_scale(sca: float):
	$CollisionShape2D.position.y = 500 * sca
	$CollisionShape2D2.position.y = -500 * sca
	$CollisionShape2D3.position.x = 1000 * sca
	$CollisionShape2D4.position.x = -1000 * sca

func _on_area_entered(area):
	area.destroy_no_effects()

func _on_body_entered(body):
	body.destroy()
