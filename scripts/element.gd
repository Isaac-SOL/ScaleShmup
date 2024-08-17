class_name Element extends Area2D

const ENEMY_LAYER = 1 << 2
const ENEMY_MASK = 1 << 1 | 1 << 8
const ENEMY_PROJECTILE_LAYER = 1 << 3
const ENEMY_PROJECTILE_MASK = 1 << 1 | 1 << 8
const PLAYER_LAYER = 1 << 8
const PLAYER_MASK = 1 << 2 | 1 << 3
const PLAYER_PROJECTILE_LAYER = 1 << 1
const PLAYER_PROJECTILE_MASK = 1 << 2 | 1 << 3

signal hp_changed(new_hp: int)
signal destroyed(element: Element)
signal destroyed_by_player(element: Element)

@export var size: int = 1
@export var hp: int = 4
@export var projectile: PackedScene
@export var player_owned: bool = false
@export var shoot_strength: float = 10

@export_group("Colors")
@export var enemy_color: Color
@export var player_color: Color

var direction: Vector2 = Vector2.ZERO
var move_to_player: bool = false

var wander_time: float = 0.0
var wander_vec: Vector2i = Vector2i(0.0, 0.0)

func _ready():
	set_mode(player_owned)

func _process(delta):
	if player_owned:
		if move_to_player:
			position = Util.decayv2(position, Vector2.ZERO, 0.1)
			if position.length() < 10:
				move_to_player = false
		else:
			position += direction * delta
	else:
		wander_time -= delta
		if wander_time < 0.0:
			wander_time = 5.0
			var angle = randi() % 360
			wander_vec.x = cos(angle) * 10
			wander_vec.y = sin(angle) * 10
		position += wander_vec * delta

func set_mode(player_mode: bool):
	player_owned = player_mode
	if player_owned:
		set_deferred("collision_layer", PLAYER_LAYER)
		set_deferred("collision_mask", PLAYER_MASK)
		%Shadow.modulate = player_color
	else:
		set_deferred("collision_layer", ENEMY_LAYER)
		set_deferred("collision_mask", ENEMY_MASK)
		%Shadow.modulate = enemy_color

func shoot(dir: Vector2):
	var new_projectile: Projectile = projectile.instantiate()
	new_projectile.player = player_owned
	new_projectile.global_position = global_position
	new_projectile.apply_impulse(dir * shoot_strength)

func destroy():
	destroyed.emit(self)
	queue_free()

func give_to_player():
	set_mode(true)
	hp = size
	move_to_player = true

func _on_shoot_timer_timeout():
	if player_owned:
		# Ask if shooting and shoot direction
		pass
	else:
		shoot((Singletons.player.global_position - global_position).normalized())

func _on_element_body_entered(body: Node2D):
	if player_owned:
		if body is Projectile and not body.player:
			body.destroy()
			hp -= body.damage_value
			if hp < 0: hp = 0
			hp_changed.emit(hp)
			if hp == 0: destroy()
	else:
		if body is Projectile and body.player:
			body.destroy()
			hp -= body.damage_value
			if hp <= 0:
				destroyed_by_player.emit(self)

func _on_area_entered(area: Area2D):
	if player_owned:
		if area is Enemy:
			area.destroy()
			hp -= area.hp
			if hp < 0: hp = 0
			hp_changed.emit(hp)
			if hp == 0: destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	destroy()
