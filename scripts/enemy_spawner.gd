class_name EnemySpawner extends Node2D

@export var enemy: PackedScene
@export var min_radius: float = 100
@export var max_radius: float = 200

func _on_timer_timeout():
	var angle: float = randf_range(0, TAU)
	var distance: float = randf_range(min_radius, max_radius)
	var pos := Vector2(sin(angle), cos(angle)) * distance
	
	var new_enemy: Enemy = enemy.instantiate()
	%EnemiesLevel1.add_child(new_enemy)
	new_enemy.global_position = position + pos
	new_enemy.destroyed_by_player.connect($"/root/Main"._on_enemy_killed)
