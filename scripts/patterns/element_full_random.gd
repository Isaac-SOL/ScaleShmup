extends Element

func shoot(dir: Vector2):
	play_audio_scaled(%AudioShoot, -20, size)
	shoot_single_projectile(projectile, dir.rotated(randf() * TAU))
