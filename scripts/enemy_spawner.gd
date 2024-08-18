class_name EnemySpawner extends Node2D

@export var enemies: Array[PackedScene]
@export var weights: Array[float]

var sizes: Array[int] = []

func _ready():
	for enemy: PackedScene in enemies:
		var elem: Element = enemy.instantiate()
		sizes.append(elem.size)
		elem.queue_free()

func _process(_delta):
	position = %Player.position
	%SpawnerPath.scale = Vector2.ONE / %Camera2D.zoom

func pick_enemy_weighted(player_size: int) -> PackedScene:
	# Choose valid spawnable enemies relative to player size
	var available_enemies: Array[PackedScene] = []
	var available_weights: Array[float] = []
	for i: int in range(len(sizes)):
		if sizes[i] >= floori(player_size / 4) and sizes[i] <= player_size * 20:
			available_enemies.append(enemies[i])
			available_weights.append(weights[i])
	if available_enemies.is_empty(): return null
	
	# Pick the enemy according to weight
	var total_weights: float = 0
	for weight: float in available_weights: total_weights += weight
	var picked_weight: float = randf() * total_weights
	var curr_weight: float = 0
	var idx: int = 0
	while curr_weight < picked_weight and idx < available_enemies.size():
		curr_weight += available_weights[idx]
		idx += 1
	return available_enemies[idx - 1]

func _on_timer_timeout():
	%SpawnerFollow.progress_ratio = randf()
	var new_enemy_scene: PackedScene = pick_enemy_weighted(Singletons.player.count_atoms())
	if new_enemy_scene:
		var new_enemy: Element = new_enemy_scene.instantiate()
		%Enemies.add_child(new_enemy)
		new_enemy.set_mode(false)
		new_enemy.global_position = %SpawnerFollow.global_position
		new_enemy.destroyed_by_player.connect($"/root/Main"._on_enemy_killed)
