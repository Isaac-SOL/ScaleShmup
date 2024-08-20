extends Element

@export var stagger_amount: int = 3
@export var stagger_interval: float = 0.5

func shoot(dir: Vector2):
	play_audio_scaled(%AudioShoot, -20, size)
	for i in range(stagger_amount):
		shoot_single_projectile(projectile, dir)
		await get_tree().create_timer(stagger_interval).timeout
