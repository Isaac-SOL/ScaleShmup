extends Element

@export_range(0.0, 360.0) var spread_angle: float = 15

func shoot(dir: Vector2):
	play_audio_scaled(%AudioShoot, -20)
	var angle_rad: float = deg_to_rad(spread_angle)
	var eff_angle: float = randf_range(-angle_rad / 2, angle_rad / 2)
	var eff_dir = dir.rotated(eff_angle)
	shoot_single_projectile(projectile, eff_dir)
