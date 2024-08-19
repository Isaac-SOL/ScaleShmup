extends Element

var intercardinal: bool = false

func shoot(_dir: Vector2):
	play_audio_scaled(%AudioShoot, -20)
	for i in range(4):
		var curr_dir = Vector2.UP.rotated((i * PI / 2) + (PI / 4 if intercardinal else 0.0))
		shoot_single_projectile(projectile, curr_dir)
	intercardinal = not intercardinal
