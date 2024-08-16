class_name PlayerAmalgam extends Node2D

@export var strong_force: float = 1

var elements: Array[RigidBody2D] = []

func _ready():
	for child: Node in get_children():
		if child is RigidBody2D:
			elements.append(child)

func _process(_delta: float):
	var move_vec := Vector2.ZERO
	if Input.is_action_pressed("up"):
		move_vec.y -= 2
	if Input.is_action_pressed("down"):
		move_vec.y += 2
	if Input.is_action_pressed("left"):
		move_vec.x -= 2
	if Input.is_action_pressed("right"):
		move_vec.x += 2
	position += move_vec

func _physics_process(_delta):
	for element: RigidBody2D in elements:
		var force_vec: Vector2 = -element.position.normalized()
		element.apply_central_force(force_vec * strong_force)
