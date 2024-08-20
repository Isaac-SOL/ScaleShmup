class_name Main extends Node2D

var pause = false
@onready var shader_rect = %ShaderRect_geometry

var previous_count: int = 1
var mult_size_factor: float = 1
var offset_factor: float = 1

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
	shader_rect.material.set_shader_parameter("mult_size", (0.5 * mult_size_factor) / %Camera2D.zoom.x)
	shader_rect.material.set_shader_parameter("offset", %Camera2D.global_position / (1000 * offset_factor))

func set_camera_zoom(size: float):
	print(size)
	if size > 150: size = 150 + (size - 150) / 2
	print(size)
	%Camera2D.set_target_zoom(Vector2.ONE * (1 / size))

func set_atom_count(count: int):
	var fake_count: int = count
	if count > 15 and previous_count <= 15:
		$EnemySpawner/Timer.wait_time = 0.66
	else:
		$EnemySpawner/Timer.wait_time = 1
	if count > 150 and shader_rect != %ShaderRect_cell:
		shader_rect.visible = false
		mult_size_factor = 0.4
		offset_factor = 2
		shader_rect = %ShaderRect_cell
		shader_rect.visible = true
	if count > 2000 and shader_rect != %ShaderRect_geometry_2:
		shader_rect.visible = false
		mult_size_factor = 0.025
		offset_factor = 35
		shader_rect = %ShaderRect_geometry_2
		shader_rect.visible = true
	if count > 5000000 and shader_rect != %ShaderRect_cell_2:
		shader_rect.visible = false
		mult_size_factor = 0.01
		offset_factor = 100
		shader_rect = %ShaderRect_cell_2
		shader_rect.visible = true
	if count > 150:
		fake_count = 150 + ((count - 150) ** 2)
	%AtomLabel.set_amount(fake_count)
	if abs(count - previous_count) >= floori(count / 3):
		%AtomLabel.animate(count > previous_count)
	previous_count = count

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
