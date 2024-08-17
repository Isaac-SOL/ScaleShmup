class_name Main extends Node2D

var pause = false

func _ready():
	Singletons.main = self
	Singletons.player_projectile_pool = %ProjectilePoolPlayer
	%PauseMenu.hide()
	# Play game song
	#NodeAudio.playAudio(NodeAudio.audioGame)

func _process(delta):
	# Pause menus
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func set_camera_zoom(size: float):
	%Camera2D.set_target_zoom(Vector2.ONE * (1 / size))
	$Player/KillArea.set_kill_scale(size)

func set_atom_count(count: int):
	%SizeLabel.text = str(count) + " atoms!"

func _on_enemy_killed(enemy: Element):
	%Player.add_element(enemy)
	enemy.give_to_player()

func _on_player_killed():
	%GameOverLayer.visible = true
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func pauseMenu():
	if pause:
		%PauseMenu.hide()
		Engine.time_scale = 1
	else:
		%PauseMenu.show()
		Engine.time_scale = 0
	pause = !pause
