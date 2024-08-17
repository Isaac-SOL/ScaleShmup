class_name Projectile extends RigidBody2D

@export var player: bool = false
@export var damage_value: int = 1

var index: float = 0

func create(sca: float = 1):
	await get_tree().process_frame
	await get_tree().process_frame
	%Sprite2D.scale = Vector2.ONE * sca
	%CollisionShape2D.shape.radius *= sca
	$VisibleOnScreenNotifier2D.scale = Vector2.ONE * sca
	visible = true

func destroy():
	%Sprite2D.scale = Vector2.ONE
	%CollisionShape2D.shape.radius = 3
	$VisibleOnScreenNotifier2D.scale = Vector2.ONE
	if player:
		Singletons.player_projectile_pool.destroy_projectile(self)
	else:
		Singletons.enemy_projectile_pool.destroy_projectile(self)

func _on_visible_on_screen_notifier_2d_screen_exited():
	destroy()
