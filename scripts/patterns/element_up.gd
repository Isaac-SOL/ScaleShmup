extends Element

func shoot(_dir: Vector2):
	play_audio_scaled(%AudioShoot, -20)
	shoot_single_projectile(projectile, Vector2.UP.rotated(global_rotation))
