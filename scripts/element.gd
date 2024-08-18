class_name Element extends Area2D

const ENEMY_LAYER = 1 << 2
const ENEMY_MASK = 1 << 1 | 1 << 8
const PLAYER_LAYER = 1 << 8
const PLAYER_MASK = 1 << 2 | 1 << 3

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

var direction := Vector2.ZERO
var move_to_player: bool = false
var max_hp: int

var wander_time : float = 0.0
var wander_countdown : float = 0.0
var speed : float = 20.0
var current_angle : float = 0.0
var old_wander := Vector2.ZERO
var current_wander := Vector2.ZERO
var constant_rotation : float

const wander_transition : float = 2.5

func _ready():
	set_mode(player_owned)
	max_hp = hp
	constant_rotation = randf_range(-PI / 2, PI / 2)

func _process(delta):
	if player_owned:
		if move_to_player:
			position = Util.decayv2(position, Vector2.ZERO, 8 * delta)
			if position.length() < 10:
				move_to_player = false
		else:
			position += direction * delta
	else:
		wander_countdown -= delta
		if wander_countdown < 0.0:
			wander_time = randf_range(3.0, 8.0)
			wander_countdown = wander_time
			current_angle = current_angle + randf_range(-90.0, 90.0)
			if current_angle <= -180.0:
				current_angle += 360.0
			if current_angle > 180.0:
				current_angle -= 360.0
			old_wander = current_wander
			current_wander = Vector2(cos(deg_to_rad(current_angle)), sin(deg_to_rad(current_angle)))
		var current_influence : float = 1.0 if wander_countdown < wander_time - 2.5 else (wander_time - wander_countdown) / 2.5
		var old_influence : float = 0.0 if wander_countdown < wander_time - 2.5 else (wander_countdown - (wander_time - 2.5)) / 2.5
		var desired_vel := current_wander * current_influence + old_wander * old_influence
		var move : Vector2 = desired_vel.normalized() * speed
		position += move * delta
	
	rotation += constant_rotation * delta
	%HPBarAnchor.global_rotation = 0

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
	Singletons.projectiles.add_child(new_projectile)
	new_projectile.global_position = global_position
	new_projectile.apply_impulse(dir * shoot_strength)

func destroy():
	Singletons.shaker.shake(1, 2 * size)
	destroyed.emit(self)
	queue_free()

func destroy_no_effects():
	destroyed.emit(self)
	queue_free()

func destroy_threshold(threshold: int):
	if size <= threshold:
		destroy_no_effects()

func change_speed(new_speed: float):
	direction = direction.normalized() * new_speed

func give_to_player():
	set_mode(true)
	hp = size
	shoot_strength = floori(shoot_strength * 1.7)
	$ShootTimer.wait_time *= 0.7
	move_to_player = true
	%HPBar.visible = false

func _on_shoot_timer_timeout():
	if player_owned:
		#if Input.is_action_pressed("shoot"):
		var shoot_position: Vector2 = get_global_mouse_position()
		var shoot_direction: Vector2 = (shoot_position - global_position).normalized()
		shoot(shoot_direction)
		if position.length() > Singletons.player.radius * 2:
			Singletons.player._on_area_exited(self)
	elif %VisibleOnScreenNotifier2D.is_on_screen():
		shoot((Singletons.player.global_position - global_position).normalized())

func _on_element_body_entered(body: Node2D):
	if player_owned:
		if body is Projectile and not body.player and not move_to_player:
			body.destroy()
			hp -= body.damage_value
			if hp < 0: hp = 0
			hp_changed.emit(hp)
			if hp == 0: destroy()
	else:
		if body is Projectile and body.player:
			body.destroy()
			hp -= body.damage_value
			var hp_ratio := float(hp) / max_hp
			%HPBar.set_ratio(hp_ratio)
			if hp_ratio <= 0.9: %HPBar.visible = true
			if hp <= 0:
				destroyed_by_player.emit(self)
				Singletons.shaker.shake(0.5, 2 * size)

func _on_area_entered(area: Area2D):
	if player_owned:
		if area is Element and not area.player_owned:
			hp -= area.hp
			if hp < 0: hp = 0
			hp_changed.emit(hp)
			if hp == 0: destroy()
	else:
		if area is Element and area.player_owned:
			hp -= area.hp
			var hp_ratio := float(hp) / max_hp
			%HPBar.set_ratio(hp_ratio)
			if hp_ratio <= 0.9: %HPBar.visible = true
			if hp <= 0: destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	destroy_no_effects()

func _on_kill_timer_timeout():
	if not %VisibleOnScreenNotifier2D.is_on_screen():
		destroy_no_effects()
