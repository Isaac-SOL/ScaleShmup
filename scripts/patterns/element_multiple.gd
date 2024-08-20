extends Element

@export_range(2, 32) var amount: int = 3
@export_range(0.0, 360.0) var angle: float = 15

func shoot(dir: Vector2):
	play_audio_scaled(%AudioShoot, -20, size)
	var angle_rad: float = deg_to_rad(angle)
	var angle_part: float = angle_rad / (amount - 1)
	var curr_angle: float = -angle_rad / 2
	for i in range(amount):
		var curr_dir: Vector2 = dir.rotated(curr_angle)
		shoot_single_projectile(projectile, curr_dir)
		curr_angle += angle_part
