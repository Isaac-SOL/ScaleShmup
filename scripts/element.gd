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
@export var player_projectile_speed_factor: float = 1
@export var flying_label: PackedScene
@export var shooting_anim: bool = true
@export var enemy_ai: bool = true

@export_group("Colors")
@export var enemy_color: Color
@export var player_color: Color

var direction := Vector2.ZERO
var move_to_player: bool = false
var max_hp: int
var anim_base_scale: Vector2

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
	speed *= sqrt(size)
	constant_rotation = randf_range(-PI / 2, PI / 2)
	anim_base_scale = %Sprite2D.scale

func _process(delta):
	if player_owned:
		if move_to_player:
			position = Util.decayv2(position, Vector2.ZERO, 8 * delta)
			if position.length() < 10:
				move_to_player = false
		else:
			position += direction * delta
	elif enemy_ai:
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

func shoot_single_projectile(proj: PackedScene, dir: Vector2,
							 strength_enemy: float = shoot_strength,
							 strength_player: float = player_projectile_speed_factor) -> Projectile:
	var new_projectile: Projectile = proj.instantiate()
	new_projectile.player = player_owned
	if size < Singletons.player.size / 80:
		new_projectile.damage_value *= Singletons.player.size / (80 * size)
	Singletons.projectiles.add_child(new_projectile)
	new_projectile.global_position = %ShootOrigin.global_position
	new_projectile.global_rotation = dir.angle() - PI / 2
	var proj_speed: float
	if player_owned:
		proj_speed = Singletons.player.sqrt_size * strength_player
	else:
		proj_speed = strength_enemy
	new_projectile.apply_impulse(dir * proj_speed)
	return new_projectile

func shoot(dir: Vector2):
	play_audio_scaled(%AudioShoot, -20, size / 4.0)
	shoot_single_projectile(projectile, dir)

func shoot_anim():
	if shooting_anim:
		var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(%Sprite2D, "scale", anim_base_scale * Vector2(0.9, 1.1), 0.25)
		tween.tween_property(%Sprite2D, "scale", anim_base_scale * Vector2(1.1, 0.9), 0.25)
		tween.tween_property(%Sprite2D, "scale", anim_base_scale, 0.25)

func destroy():
	play_audio_scaled(%AudioDestroy, -6, size)
	Singletons.shaker.shake(sqrt(size), 1)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	direction = Vector2.ZERO
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(%Sprite2D, "scale", %Sprite2D.scale * 1.3, 0.5)
	tween.tween_property(%Sprite2D, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_property(%Shadow, "scale", %Shadow.scale * 1.3, 0.5)
	tween.tween_property(%Shadow, "modulate", Color.TRANSPARENT, 0.5)
	tween.chain().tween_callback(func(): queue_free())
	destroyed.emit(self)

func destroy_no_effects():
	destroyed.emit(self)
	queue_free()

func destroy_threshold(threshold: int):
	if (size <= threshold and not player_owned) or size <= threshold / 10:
		destroy_no_effects()

func destroy_not_player(threshold: int):
	if not player_owned:
		destroy_no_effects()

func change_speed(new_speed: float):
	direction = direction.normalized() * new_speed

func give_to_player():
	play_audio_scaled(%AudioDestroy, -18, size)
	play_audio_scaled(%AudioWin, -24, size)
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
		var shoot_direction: Vector2 = (shoot_position - %ShootOrigin.global_position).normalized()
		shoot_anim()
		shoot(shoot_direction)
		if position.length() > Singletons.player.radius * 2:
			Singletons.player._on_area_exited(self)
	elif %VisibleOnScreenNotifier2D.is_on_screen():
		if enemy_ai or Singletons.player.size > size / 10:
			shoot_anim()
			shoot((Singletons.player.global_position - %ShootOrigin.global_position).normalized())

func instantiate_damage_label(pos: Vector2, damage: int):
	var low_threshold: int =  Singletons.player.size / 200
	if damage < Singletons.player.size / 200: return
	var dmg_scale: float = (damage - low_threshold) / ((Singletons.player.size / 10.0) - low_threshold)
	dmg_scale = clampf(dmg_scale, 0.2, 1)
	var inst_pos: Vector2 = lerp(position, pos, 0.75)
	var dmg_label: FlyingLabel = flying_label.instantiate()
	dmg_label.text = str(damage)
	dmg_label.final_scale = dmg_scale
	Singletons.labels.add_child(dmg_label)
	dmg_label.position = inst_pos
	dmg_label.scale = (Vector2.ONE / Singletons.camera.zoom) / 3

func play_audio_scaled(source: AudioStreamPlayer, base_db: float, scale_value: float):
	if scale_value < Singletons.player.size / 100: return
	source.volume_db = base_db
	if scale_value < Singletons.player.size / 20:
		var t: float = ((Singletons.player.size / size) - 20) / 80
		source.volume_db = lerp(base_db, -60.0, t)
	if source == %AudioWin:
		var chain: int = Singletons.main.increment_chain()
		source.pitch_scale = 1.0 + 0.05 * chain
	source.play()

func _on_element_body_entered(body: Node2D):
	if player_owned:
		if body is Projectile and not body.player and not move_to_player:
			body.destroy()
			if Singletons.player.immunity <= 0:
				if body.damage_value < Singletons.player.size / 20:
					body.damage_value /= 10
				play_audio_scaled(%AudioHit, -10, body.damage_value)
				hp -= ceili(body.damage_value / 8.0)
				if hp < 0: hp = 0
				hp_changed.emit(hp)
				if hp == 0: destroy()
	else:
		if body is Projectile and body.player:
			play_audio_scaled(%AudioHit, -10, min(body.damage_value, size))
			instantiate_damage_label(body.position, body.damage_value)
			body.destroy()
			hp -= body.damage_value
			var hp_ratio := float(hp) / max_hp
			%HPBar.set_ratio(hp_ratio)
			if hp_ratio <= 0.9: %HPBar.visible = true
			if hp <= 0:
				destroyed_by_player.emit(self)
				Singletons.shaker.shake(sqrt(size), 0.5)

func _on_area_entered(area: Area2D):
	if player_owned:
		if area is Element and not area.player_owned and Singletons.player.immunity <= 0:
			play_audio_scaled(%AudioHit, -10, area.size)
			hp -= min(area.hp, ceili(size / 3.0))
			if hp < 0: hp = 0
			hp_changed.emit(hp)
			if hp == 0: destroy()
	else:
		if area is Element and area.player_owned:
			play_audio_scaled(%AudioHit, -10, min(area.size, size))
			instantiate_damage_label(area.position, area.hp)
			hp -= min(area.hp, ceili(area.size / 3.0))
			var hp_ratio := float(hp) / max_hp
			%HPBar.set_ratio(hp_ratio)
			if hp_ratio <= 0.9: %HPBar.visible = true
			if hp <= 0:
				destroyed_by_player.emit(self)
				Singletons.shaker.shake(sqrt(size * 2), 1)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if enemy_ai:
		destroy_no_effects()

func _on_kill_timer_timeout():
	if not %VisibleOnScreenNotifier2D.is_on_screen() and enemy_ai:
		destroy_no_effects()
