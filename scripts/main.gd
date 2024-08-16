class_name Main extends Node2D

static var instance: Main

func _ready():
	instance = self

func set_player_size(size: int):
	%Player.set_size(size)
	%Camera2D.zoom = Vector2.ONE * (1 / (log(size) / log(2)))
	%SizeLabel.text = str(size) + " atoms!"

func _on_enemy_killed(size: int):
	set_player_size(%Player.size + size)
