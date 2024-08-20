class_name Main extends Node2D

@export var black_hole: PackedScene

var pause = false
@onready var shader_rect = %ShaderRect_geometry
@onready var player = %Player
@onready var anim_player = $AnimationPlayer

var previous_count: int = 1
var mult_size_factor: float = 1
var offset_factor: float = 1
var chain: int = 0
var chain_timer: float = 0.0
var boss_spawned: bool = false

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
	var shader_scale: Vector2 = Vector2.ONE / %Camera2D.zoom
	%ShaderRect_volcano.scale = shader_scale
	%ShaderRect_trip.scale = shader_scale
	%ShaderRect_cell.scale = shader_scale
	%ShaderRect_geometry.scale = shader_scale
	shader_rect.material.set_shader_parameter("mult_size", (0.5 * mult_size_factor) / %Camera2D.zoom.x)
	shader_rect.material.set_shader_parameter("offset", %Camera2D.global_position / (1000 * offset_factor))
	if shader_rect == %ShaderRect_stars2:
		var dir = player.direction*0.01
		if dir == Vector2(0.0,0.0):
			dir = Vector2(1.0,1.0)
			print("Dir == 0 > dir = "+str(dir))
		else:
			print("Dir != 0 > dir = "+str(dir))
		shader_rect.material.set_shader_parameter("speed_vec", dir)
	
	if chain_timer > 0.0:
		chain_timer -= delta
		if chain_timer <= 0.0:
			chain = 0

func set_camera_zoom(size: float):
	if size > 150: size = 150 + (size - 150) / 2
	%Camera2D.set_target_zoom(Vector2.ONE * (1 / size))

func set_atom_count(count: int):
	var fake_count: int = count
	if count > 15 and previous_count <= 15:
		$EnemySpawner/Timer.wait_time = 0.66
	else:
		$EnemySpawner/Timer.wait_time = 1
	if count > 150 and count < 1500 and shader_rect != %ShaderRect_cell:
		#shader_rect.visible = false
		mult_size_factor = 0.4
		offset_factor = 2
		shader_rect = %ShaderRect_cell
		anim_player.queue("cells_on")
		#shader_rect.visible = true
	if count > 2000 and count < 650000 and shader_rect != %ShaderRect_trip:
		#shader_rect.visible = false
		mult_size_factor = 0.025
		offset_factor = 35
		shader_rect = %ShaderRect_trip
		anim_player.queue("trip_on")
		#shader_rect.visible = true
	if count > 750000 and count < 3000000 and shader_rect != %ShaderRect_volcano:
		mult_size_factor = 0.01
		offset_factor = 100
		shader_rect = %ShaderRect_volcano
		anim_player.queue("volcano_on")
	if count > 5000000 and shader_rect != %ShaderRect_stars2:
		#shader_rect.visible = false
		mult_size_factor = 0.001
		offset_factor = 1000
		shader_rect = %ShaderRect_stars2
		anim_player.queue("stars_on")
		#%ParallaxBackgroundStars.visible = true
	
	if count > 150:
		fake_count = 150 + ((count - 150) ** 2)
	%AtomLabel.set_amount(fake_count)
	if abs(count - previous_count) >= floori(count / 3):
		%AtomLabel.animate(count > previous_count)
	previous_count = count
	
	if count >= 100000000 and not boss_spawned:
		boss_spawned = true
		get_tree().call_group("Element", "destroy_not_player")
		$EnemySpawner.process_mode = Node.PROCESS_MODE_DISABLED
		var hole: BlackHole = black_hole.instantiate()
		hole.global_position = player.global_position + Vector2(0, -600000)
		%Enemies.add_child(hole)
		hole.destroyed_by_player.connect(_on_black_hole_killed)
		await get_tree().create_timer(5).timeout
		hole.start()

func increment_chain() -> int:
	var prev_chain := chain
	chain += 1
	chain_timer = 5.0
	return prev_chain

func _on_enemy_killed(enemy: Element):
	%Player.add_element(enemy)
	enemy.give_to_player()

func _on_black_hole_killed(hole: BlackHole):
	%WinLayer.visible = true
	get_tree().paused = true

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
