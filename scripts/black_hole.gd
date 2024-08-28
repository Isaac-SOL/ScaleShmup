class_name BlackHole extends Node2D

signal destroyed_by_player(hole: BlackHole)

@export var poses: Array[Texture2D]
@export var trail_poses: Array[Texture2D] 
@export var trails: Array[Sprite2D]
@export var move_distance = 1
@export var projectile: PackedScene
@export var flying_label: PackedScene
@export var hp: int
@export var size: int
@export var test_mode = false

var next_pattern: int = 0

@onready var target: Vector2 = global_position
var last_pose: int = 0
@onready var max_hp: int = hp

func _process(delta):
	var prev_pos: Vector2 = target
	%Hitbox.global_position = Util.decayv2(%Hitbox.global_position, prev_pos, delta)
	prev_pos = %Hitbox.global_position
	for node: Node2D in trails:
		node.global_position = Util.decayv2(node.global_position, prev_pos, 10 * delta)
		prev_pos = node.global_position

func start():
	$Timer.start()
	$TimerMove.start()
	_on_timer_timeout()
	_on_timer_move_timeout()

func move():
	%AudioVoice.play()
	target = %Hitbox.global_position + Vector2(500 * scale.x, 0) * (1 if %Hitbox.global_position.x < 0 else -1)

func shoot_single_projectile(proj: PackedScene, dir: Vector2, strength_enemy) -> Projectile:
	var new_projectile: Projectile = proj.instantiate()
	new_projectile.player = false
	if size < Singletons.player.size / 80:
		new_projectile.damage_value *= Singletons.player.size / (80 * size)
	Singletons.projectiles.add_child(new_projectile)
	new_projectile.global_position = %Hitbox.global_position
	new_projectile.global_rotation = dir.angle() - PI / 2
	var proj_speed: float
	proj_speed = strength_enemy
	new_projectile.apply_impulse(dir * proj_speed)
	return new_projectile

func shoot():
	%AudioShoot.play()
	if test_mode: return
	var dir = (Singletons.player.global_position - %Hitbox.global_position).normalized()
	if next_pattern == 0:
		shoot_multiple(dir, 4, 60)
		next_pattern = 1
	elif next_pattern == 1:
		shoot_multiple(dir, 5, 100)
		next_pattern = 0

func shoot_multiple(dir: Vector2, amount: int, angle: float):
	var angle_rad: float = deg_to_rad(angle)
	var angle_part: float = angle_rad / (amount - 1)
	var curr_angle: float = -angle_rad / 2
	for i in range(amount):
		var curr_dir: Vector2 = dir.rotated(curr_angle)
		shoot_single_projectile(projectile, curr_dir, 800000)
		curr_angle += angle_part

func shoot_omni():
	for i in range(32):
		var curr_dir = Vector2.UP.rotated(i * PI / 16)
		shoot_single_projectile(projectile, curr_dir, 800000)

func change_pose():
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(%Sprite2D, "scale", Vector2(1, 0.8), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_callback(change_pose_effective)
	tween.tween_callback(shoot)
	tween.tween_property(%Sprite2D, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_IN)

func change_pose_effective():
	var i: int = last_pose
	while i == last_pose: i = randi_range(0, poses.size() - 1)
	last_pose = i
	%Sprite2D.texture = poses[i]
	for trail in trails:
		await get_tree().create_timer(0.15).timeout
		trail.texture = trail_poses[i]

func _on_timer_timeout():
	change_pose()

func _on_timer_move_timeout():
	move()

func play_audio_scaled(source: AudioStreamPlayer, base_db: float, scale_value: float):
	if test_mode: return
	if scale_value < Singletons.player.size / 100: return
	source.volume_db = base_db
	if scale_value < Singletons.player.size / 20:
		var t: float = ((Singletons.player.size / size) - 20) / 80
		source.volume_db = lerp(base_db, -60.0, t)
	source.play()

func instantiate_damage_label(pos: Vector2, damage: int):
	if test_mode: return
	var inst_pos: Vector2 = lerp(%Hitbox.global_position, pos, 0.75)
	var dmg_label: FlyingLabel = flying_label.instantiate()
	dmg_label.text = str(damage)
	Singletons.labels.add_child(dmg_label)
	dmg_label.global_position = inst_pos
	dmg_label.scale = (Vector2.ONE / Singletons.camera.zoom) / 6

func _on_hitbox_area_entered(_area):
	Singletons.shaker.shake(sqrt(size * 2), 1)

func _on_hitbox_body_entered(body):
	if body is Projectile and body.player:
		play_audio_scaled(%AudioHit, -10, min(body.damage_value, size))
		instantiate_damage_label(body.position, body.damage_value)
		body.destroy()
		hp -= body.damage_value
		if hp <= 0:
			end_sequence()

func bwob():
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(%Sprite2D, "scale", Vector2(0.7, 1.3), 0.25)
	tween.tween_property(%Sprite2D, "scale", Vector2(1.3, 0.7), 0.25)
	tween.tween_property(%Sprite2D, "scale", Vector2.ONE, 0.25)

func end_sequence():
	%Hitbox.set_deferred("collision_mask", 0)
	%Hitbox.set_deferred("collision_layer", 0)
	$Timer.stop()
	$TimerMove.stop()
	bwob()
	shoot_omni.call_deferred()
	%AudioSmallBoom.play()
	Singletons.shaker.shake(sqrt(size * 2), 1)
	await get_tree().create_timer(1).timeout
	bwob()
	shoot_omni.call_deferred()
	%AudioSmallBoom.play()
	Singletons.shaker.shake(sqrt(size * 2), 1)
	await get_tree().create_timer(1).timeout
	bwob()
	shoot_omni.call_deferred()
	%AudioSmallBoom.play()
	Singletons.shaker.shake(sqrt(size * 2), 1)
	await get_tree().create_timer(1).timeout
	%AudioBigBoom.play()
	shoot_omni.call_deferred()
	Singletons.shaker.shake(sqrt(size * 5), 2)
	visible = false
	await get_tree().create_timer(3).timeout
	destroyed_by_player.emit(self)
