extends Element

@export var amount: int = 10
@export_range(0.0, 360.0) var spread_angle: float = 15
@export var spread_strength: float = 0.2
@export var shoot_up: bool = false

func shoot(dir: Vector2):
	if shoot_up:
		dir = Vector2.UP.rotated(global_rotation)
	play_audio_scaled(%AudioShoot, -20, size)
	var angle_rad: float = deg_to_rad(spread_angle)
	for i in range(amount):
		var eff_angle: float = randf_range(-angle_rad / 2, angle_rad / 2)
		var eff_strength = randf_range(1 - spread_strength, 1 + spread_strength)
		var eff_dir = dir.rotated(eff_angle)
		shoot_single_projectile(projectile, eff_dir, shoot_strength * eff_strength, player_projectile_speed_factor * eff_strength)
