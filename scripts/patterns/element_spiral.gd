extends Element

func _process(delta):
	super._process(delta)

func shoot(_dir: Vector2):
	play_audio_scaled(%AudioShoot, -20, size)
	for i in range(4):
		var curr_dir = Vector2.UP.rotated(global_rotation + (i * PI / 2))
		shoot_single_projectile(projectile, curr_dir)
