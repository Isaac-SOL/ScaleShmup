class_name Player extends Area2D

signal killed

@export var move_speed: float = 1
@export var projectile: PackedScene
@export var projectile_speed: float = 1
@export var base_fire_rate: float = 1
@export var part_speed: float = 10

@onready var radius = %CollisionShape2D.shape.radius
@onready var fire_rate = base_fire_rate
@onready var elements: Array[Element] = [$Elements/Atom]
var next_fire: float = 0
var parts_level: int = 1
var internal_atoms: int = 0
var atom_threshold: int = 1
var base_radius: float

func _ready():
	Singletons.player = self
	$Elements/Atom.direction = Util.rand_on_circle(part_speed)
	base_radius = %CollisionShape2D.shape.radius

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
	#if Input.is_action_pressed("shoot"):
	#	while next_fire <= 0:
	#		next_fire += fire_rate
	#		shoot()

func shoot():
	var shoot_position: Vector2 = get_global_mouse_position()
	var shoot_direction: Vector2 = (shoot_position - global_position).normalized()
	
	var rand_elem = elements[randi_range(0, elements.size() - 1)]
	var new_projectile: RigidBody2D = Singletons.player_projectile_pool.create_projectile(rand_elem.global_position, atom_threshold)
	if new_projectile:
		new_projectile.damage_value = atom_threshold
		new_projectile.apply_impulse(shoot_direction * projectile_speed)

func set_radius(new_radius: int):
	radius = new_radius
	%CollisionShape2D.shape.radius = radius * 1000
	if radius > 1:
		Singletons.main.set_camera_zoom(log(radius) / log(2))
		%Shadow.scale = Vector2.ONE * (log(radius) / log(2))

func add_atoms(amount: int):
	internal_atoms += amount
	Singletons.main.set_atom_count(count_atoms())
	fire_rate = base_fire_rate / elements.size()
	set_radius(count_atoms())
	while internal_atoms >= atom_threshold:
		internal_atoms -= atom_threshold
		add_part()
	if elements.size() >= 96:
		increase_level()

func add_part():
	var new_part: PlayerPart = null #part.instantiate()
	await get_tree().process_frame
	%Parts.add_child(new_part)
	new_part.position = Util.rand_in_circle(0, radius)
	new_part.direction = Util.rand_on_circle(part_speed)
	new_part.hp_changed.connect(_on_part_hp_changed)
	new_part.destroyed.connect(_on_part_destroyed)
	new_part.set_level(parts_level, atom_threshold)
	#parts.append(new_part)
	
	Singletons.main.set_atom_count(count_atoms())
	fire_rate = base_fire_rate / elements.size()
	set_radius(count_atoms())

func add_element(elem: Element):
	await get_tree().process_frame
	var elem_pos: Vector2 = elem.global_position
	elem.get_parent().remove_child(elem)
	%Elements.add_child(elem)
	elem.global_position = elem_pos
	elem.hp_changed.connect(_on_part_hp_changed)
	elem.destroyed.connect(_on_part_destroyed)
	elem.direction = Util.rand_on_circle(part_speed)
	elements.append(elem)
	
	Singletons.main.set_atom_count(count_atoms())
	fire_rate = base_fire_rate / elements.size()
	set_radius(count_atoms())

func count_atoms() -> int:
	var total: int = internal_atoms
	for elem: Element in elements:
		if elem:
			total += elem.hp
	return total

func increase_level():
	var fixed_count := count_atoms()
	parts_level += 1
	elements = []
	for child in %Parts.get_children():
		child.queue_free()
	atom_threshold *= 12
	internal_atoms = fixed_count
	while internal_atoms >= atom_threshold:
		add_part()
		internal_atoms -= atom_threshold

func decrease_level():
	var fixed_count := count_atoms()
	parts_level -= 1
	elements = []
	for child in %Parts.get_children():
		child.queue_free()
	atom_threshold /= 12
	internal_atoms = fixed_count
	while internal_atoms >= atom_threshold:
		add_part()
		internal_atoms -= atom_threshold

func _on_area_exited(area: Area2D):
	if area is Element:
		var new_target := Util.rand_in_circle(0, radius)
		area.direction = (new_target - area.position).normalized() * part_speed

func _on_part_hp_changed(_new_hp: int):
	Singletons.main.set_atom_count(count_atoms())
	fire_rate = base_fire_rate / elements.size()
	set_radius(count_atoms())

func _on_part_destroyed(elem: Element):
	Singletons.main.set_atom_count(count_atoms())
	elements.erase(elem)
	fire_rate = base_fire_rate / elements.size()
	set_radius(count_atoms())
	if count_atoms() == 0:
		killed.emit()
	if elements.size() < 4 and parts_level > 1:
		decrease_level()
