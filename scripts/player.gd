class_name Player extends Area2D

@export var size = 1
@export var move_speed: float = 1
@export var projectile: PackedScene
@export var projectile_speed: float = 1


func _process(_delta: float):
	var move_vec := Vector2.ZERO
	if Input.is_action_pressed("up"):
		move_vec.y -= move_speed
	if Input.is_action_pressed("down"):
		move_vec.y += move_speed
	if Input.is_action_pressed("left"):
		move_vec.x -= move_speed
	if Input.is_action_pressed("right"):
		move_vec.x += move_speed
	position += move_vec
	
	if Input.is_action_just_pressed("shoot"):
		var shoot_position: Vector2 = get_global_mouse_position()
		var shoot_direction: Vector2 = (shoot_position - global_position).normalized()
		
		var new_projectile: RigidBody2D = projectile.instantiate()
		get_parent().add_child(new_projectile)
		new_projectile.position = position
		new_projectile.apply_impulse(shoot_direction * projectile_speed)

func set_size(new_size: int):
	size = new_size
	scale = Vector2.ONE * (log(size) / log(2))
