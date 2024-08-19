class_name Main extends Node2D

var pause = false
@onready var shader_rect = %ShaderRect_geometry

func _ready():
	Singletons.main = self
	Singletons.projectiles = %Projectiles
	Singletons.camera = %Camera2D
	Singletons.labels = %Labels
	%PauseMenu.hide()
	# Play game song
	#NodeAudio.playAudio(NodeAudio.audioGame)

func _process(delta):
	# Pause menus
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	shader_rect.scale = Vector2.ONE / %Camera2D.zoom
	shader_rect.material.set_shader_parameter("mult_size", 0.5 / %Camera2D.zoom.x)
	shader_rect.material.set_shader_parameter("offset", %Camera2D.global_position / 1000)

func set_camera_zoom(size: float):
	if size > 46656: size = 46656 + (size - 46656) / 2
	%Camera2D.set_target_zoom(Vector2.ONE * (1 / size))

func set_atom_count(count: int):
	var fake_count: int = count
	if count > 15:
		$EnemySpawner/Timer.wait_time = 0.66
	else:
		$EnemySpawner/Timer.wait_time = 1
	if count > 150:
		fake_count = 150 + ((count - 150) ** 2)
	%SizeLabel.text = str(fake_count) + " atoms!"

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
