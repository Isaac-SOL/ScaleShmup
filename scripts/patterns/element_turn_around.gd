extends Element

@export_range(0.0, 360.0) var angle_per_shoot: float = 15

var current_angle_pattern: float = 0

func shoot(_dir: Vector2):
	play_audio_scaled(%AudioShoot, -20, size)
	var dir := Vector2.UP.rotated(current_angle_pattern)
	shoot_single_projectile(projectile, dir)
	current_angle_pattern += angle_per_shoot
