class_name Player extends Area2D

signal killed

@export var base_move_speed: float = 0.1
@export var projectile: PackedScene
@export var projectile_speed: float = 1
@export var base_fire_rate: float = 1
@export var base_part_speed: float = 10
@export var immunity_length: float = 1


@onready var elements: Array[Element] = [$Elements/Atom]

var parts_level: int = 1
var internal_atoms: int = 0
var atom_threshold: int = 1
var radius: float
var base_radius: float
var part_speed: float
var move_speed: float
var immunity: float = 0
var size: int = 1
var sqrt_size: float = 1
var direction: Vector2
var add = 0
var target: Vector2
var going_to_target: float = 0

func _ready():
	Singletons.player = self
	part_speed = base_part_speed
	move_speed = base_move_speed
	$Elements/Atom.direction = Util.rand_on_circle(part_speed)
	radius = %CollisionShape2D.shape.radius
	base_radius = radius

func _process(delta: float):
	if going_to_target > 0:
		global_position = Util.decayv2(global_position, target, 8 * delta)
		going_to_target -= delta
	else:
		var move_vec := Vector2.ZERO
		if Input.is_action_pressed("up"):
			move_vec.y -= 1
		if Input.is_action_pressed("down"):
			move_vec.y += 1
		if Input.is_action_pressed("left"):
			move_vec.x -= 1
		if Input.is_action_pressed("right"):
			move_vec.x += 1
		move_vec = move_vec.normalized() * move_speed
		direction = move_vec
		position += move_vec * delta
	
	if immunity > 0:
		immunity -= delta

#DEBUG
func add_debug(x):
	add += x
	get_tree().call_group("MainGroup", "set_atom_count",add)

func update_size(atom_count: int):
	if atom_count > 100000000: atom_count = 100000000
	size = atom_count
	sqrt_size = sqrt(atom_count)
	Singletons.main.set_atom_count(size)
	var atom_surface: float = sqrt(atom_count)
	radius = atom_surface * base_radius
	%CollisionShape2D.shape.set_radius(radius)
	Singletons.main.set_camera_zoom(atom_surface)
	%Shadow.scale = Vector2.ONE * (atom_surface)
	part_speed = base_part_speed * atom_surface
	for elem: Element in elements:
		elem.change_speed(part_speed)
	move_speed = base_move_speed * atom_surface

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
	
	update_size(count_atoms())
	get_tree().call_group("Element", "destroy_threshold", size / 100)

func count_atoms() -> int:
	var total: int = internal_atoms
	for elem: Element in elements:
		if elem:
			total += elem.hp
	return total

#unused
func increase_level():
	var fixed_count := count_atoms()
	parts_level += 1
	elements = []
	for child in %Parts.get_children():
		child.queue_free()
	atom_threshold *= 12
	internal_atoms = fixed_count
	while internal_atoms >= atom_threshold:
		#add_part()
		internal_atoms -= atom_threshold

#unused
func decrease_level():
	var fixed_count := count_atoms()
	parts_level -= 1
	elements = []
	for child in %Parts.get_children():
		child.queue_free()
	atom_threshold /= 12
	internal_atoms = fixed_count
	while internal_atoms >= atom_threshold:
		#add_part()
		internal_atoms -= atom_threshold

func _on_area_exited(area: Area2D):
	if area is Element and area.player_owned:
		var new_target := Util.rand_in_circle(0, radius)
		area.direction = (new_target - area.position).normalized() * part_speed

func _on_area_entered(area: Area2D):
	if area.get_parent() is BlackHole:
		var throw_vector: Vector2 = global_position - area.global_position
		target = global_position + throw_vector * 4
		going_to_target = 1.0

func _on_part_hp_changed(_new_hp: int):
	update_size(count_atoms())

func _on_part_destroyed(elem: Element):
	elements.erase(elem)
	update_size(count_atoms())
	immunity = immunity_length
	if size == 0:
		killed.emit()
	if elements.size() < 4 and parts_level > 1:
		decrease_level()
