extends Element

func shoot(_dir: Vector2):
	play_audio_scaled(%AudioShoot, -20)
	for i in range(16):
		var curr_dir = Vector2.UP.rotated(i * PI / 8)
		shoot_single_projectile(projectile, curr_dir)
