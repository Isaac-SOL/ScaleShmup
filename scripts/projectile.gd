class_name Projectile extends RigidBody2D

const ENEMY_PROJECTILE_LAYER = 1 << 3
const ENEMY_PROJECTILE_MASK = 1 << 8
const PLAYER_PROJECTILE_LAYER = 1 << 1
const PLAYER_PROJECTILE_MASK = 1 << 2

@export var player: bool = false
@export var damage_value: int = 1

@export_group("Colors")
@export var player_color: Color
@export var enemy_color: Color

var index: float = 0

func _ready():
	set_mode(player)

func set_mode(player_mode: bool):
	player = player_mode
	if player:
		set_deferred("collision_layer", PLAYER_PROJECTILE_LAYER)
		set_deferred("collision_mask", PLAYER_PROJECTILE_MASK)
		%Shadow.modulate = player_color
	else:
		set_deferred("collision_layer", ENEMY_PROJECTILE_LAYER)
		set_deferred("collision_mask", ENEMY_PROJECTILE_MASK)
		%Shadow.modulate = enemy_color

func create(sca: float = 1):
	await get_tree().process_frame
	await get_tree().process_frame
	%Sprite2D.scale = Vector2.ONE * sca
	%CollisionShape2D.shape.radius *= sca
	$VisibleOnScreenNotifier2D.scale = Vector2.ONE * sca
	visible = true

func destroy():
	queue_free()
	return
	%Sprite2D.scale = Vector2.ONE
	%CollisionShape2D.shape.radius = 3
	$VisibleOnScreenNotifier2D.scale = Vector2.ONE
	if player:
		Singletons.player_projectile_pool.destroy_projectile(self)
	else:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	destroy()
