class_name Main extends Node2D

static var instance: Main
var pause = false

func _ready():
	%PauseMenu.hide()
	instance = self

func _process(delta):
	
	# Play game song
	#NodeAudio.playAudio(NodeAudio.audioGame)
	
	# Pause menus
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func set_player_size(size: int):
	%Player.set_size(size)
	%Camera2D.zoom = Vector2.ONE * (1 / (log(size) / log(2)))
	%SizeLabel.text = str(size) + " atoms!"

func _on_enemy_killed(size: int):
	set_player_size(%Player.size + size)

func pauseMenu():
	if pause:
		%PauseMenu.hide()
		Engine.time_scale = 1
	else:
		%PauseMenu.show()
		Engine.time_scale = 0
	pause = !pause
