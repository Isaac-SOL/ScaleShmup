class_name EnemySpawner extends Node2D

@export var enemy: PackedScene
@export var min_radius: float = 100
@export var max_radius: float = 200

func _process(_delta):
	position = %Player.position
	%SpawnerPath.scale = Vector2.ONE / %Camera2D.zoom

func _on_timer_timeout():
	%SpawnerFollow.progress_ratio = randf()
	var new_enemy: Element = enemy.instantiate()
	%EnemiesLevel1.add_child(new_enemy)
	new_enemy.set_mode(false)
	new_enemy.global_position = %SpawnerFollow.global_position
	new_enemy.destroyed_by_player.connect($"/root/Main"._on_enemy_killed)
