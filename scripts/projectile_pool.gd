class_name ProjectilePool extends Node2D

@export var pool_size: int = 1000
@export var projectile: PackedScene

var pool: Array[Projectile] = []
var active: Array[bool] = []
var active_amount: int = 0

func _ready():
	for i in range(pool_size):
		var new_projectile: Projectile = projectile.instantiate()
		add_child(new_projectile)
		new_projectile.process_mode = Node.PROCESS_MODE_DISABLED
		new_projectile.visible = false
		new_projectile.index = i
		pool.append(new_projectile)
		active.append(false)

func create_projectile(pos: Vector2, sca: float) -> Projectile:
	var i: int = 0
	while i < pool_size and active[i]: i += 1
	if i >= pool_size: return null
	active[i] = true
	PhysicsServer2D.body_set_state(pool[i].get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D.IDENTITY.translated(pos))
	pool[i].process_mode = Node.PROCESS_MODE_INHERIT
	pool[i].create(sca)
	active_amount += 1
	%SizeLabel2.text = str(active_amount) + " active"
	return pool[i]

func destroy_projectile(proj: Projectile):
	var index = proj.index
	if index != -1 and active[index]:
		active[index] = false
		pool[index].linear_velocity = Vector2.ZERO
		pool[index].angular_velocity = 0
		pool[index].process_mode = Node.PROCESS_MODE_DISABLED
		pool[index].visible = false
		active_amount -= 1
		%SizeLabel2.text = str(active_amount) + " active"
