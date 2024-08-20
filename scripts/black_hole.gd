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


var target: Vector2
var last_pose: int = 0
@onready var max_hp: int = hp

func _process(delta):
	var prev_pos: Vector2 = target
	%Hitbox.global_position = Util.decayv2(%Hitbox.global_position, prev_pos, delta)
	prev_pos = %Hitbox.global_position
	for node: Node2D in trails:
		node.global_position = Util.decayv2(node.global_position, prev_pos, 10 * delta)
		prev_pos = node.global_position

func move():
	target = %Hitbox.global_position + (Vector2(500, 0) if randf() < 0.5 else Vector2(-500, 0))

func shoot_single_projectile(proj: PackedScene, dir: Vector2, strength_enemy) -> Projectile:
	var new_projectile: Projectile = proj.instantiate()
	new_projectile.player = false
	if size < Singletons.player.size / 80:
		new_projectile.damage_value *= Singletons.player.size / (80 * size)
	Singletons.projectiles.add_child(new_projectile)
	new_projectile.global_position = %ShootOrigin.global_position
	new_projectile.global_rotation = dir.angle() - PI / 2
	var proj_speed: float
	proj_speed = strength_enemy
	new_projectile.apply_impulse(dir * proj_speed)
	return new_projectile

func shoot():
	#%AudioShoot.play()
	#var dir = (Singletons.player.global_position - %Hitbox.global_position).normalized()
	pass

func change_pose():
	#%AudioVoice.play()
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_QUAD)
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
	if scale_value < Singletons.player.size / 100: return
	source.volume_db = base_db
	if scale_value < Singletons.player.size / 20:
		var t: float = ((Singletons.player.size / size) - 20) / 80
		source.volume_db = lerp(base_db, -60.0, t)
	source.play()

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

func _on_hitbox_area_entered(area):
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

func _on_hitbox_body_entered(body):
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
