extends Element

func shoot(_dir: Vector2):
	play_audio_scaled(%AudioShoot, -20, size)
	for i in range(12):
		var curr_dir = Vector2.UP.rotated(i * PI / 6)
		shoot_single_projectile(projectile, curr_dir)
	await get_tree().create_timer(0.25).timeout
	play_audio_scaled(%AudioShoot, -20, size)
	for i in range(12):
		var curr_dir = Vector2.UP.rotated(i * (PI / 6) + (PI / 12))
		shoot_single_projectile(projectile, curr_dir)
