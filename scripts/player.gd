class_name Player extends Area2D

@export var size = 1
@export var move_speed: float = 1
@export var projectile: PackedScene
@export var projectile_speed: float = 1
@export var part: PackedScene
@export var base_fire_rate: float = 1

@onready var radius = %CollisionShape2D.shape.radius
@onready var fire_rate = base_fire_rate

var next_fire: float = 0

func _process(delta: float):
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
	
	if next_fire > 0:
		next_fire -= delta
	if Input.is_action_pressed("shoot"):
		while next_fire <= 0:
			next_fire += fire_rate
			shoot()

func shoot():
	var shoot_position: Vector2 = get_global_mouse_position()
	var shoot_direction: Vector2 = (shoot_position - global_position).normalized()
	
	if %Parts.get_child_count() == 0:
		var new_projectile: RigidBody2D = projectile.instantiate()
		get_parent().add_child(new_projectile)
		new_projectile.position = position
		new_projectile.apply_impulse(shoot_direction * projectile_speed)
	else:
		var rand_part = %Parts.get_child(randi_range(0, %Parts.get_child_count() - 1))
		var new_projectile: RigidBody2D = projectile.instantiate()
		get_parent().add_child(new_projectile)
		new_projectile.global_position = rand_part.global_position
		new_projectile.apply_impulse(shoot_direction * projectile_speed)

func set_size(new_size: int):
	size = new_size
	radius = size
	fire_rate = base_fire_rate / size
	%CollisionShape2D.shape.radius = radius
	add_part()
	#scale = Vector2.ONE * (log(size) / log(2))

func add_part():
	var new_part: PlayerPart = part.instantiate()
	await get_tree().process_frame
	%Parts.add_child(new_part)
	new_part.position = Util.rand_in_circle(0, radius)
	new_part.direction = Util.rand_on_circle(10)

func _on_area_exited(area: Area2D):
	if area is PlayerPart:
		var new_target := Util.rand_in_circle(0, radius)
		area.direction = (new_target - area.position).normalized() * 10
