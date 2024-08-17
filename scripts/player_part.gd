class_name PlayerPart extends Area2D

signal hp_changed(new_hp: int)
signal destroyed(part: PlayerPart)

var direction: Vector2 = Vector2.ZERO
var level: int = 1
var hp: int = 1

func _process(delta):
	position += direction * delta

func set_level(lv: int, new_hp: int):
	level = lv
	hp = new_hp
	scale = Vector2.ONE * new_hp

func destroy():
	destroyed.emit(self)
	queue_free()

func _on_body_entered(body: Node2D):
	if body is Projectile and not body.player:
		body.destroy()
		hp -= body.damage_value
		if hp < 0: hp = 0
		hp_changed.emit(hp)
		if hp == 0: destroy()

func _on_area_entered(area: Area2D):
	if area is Element and not area.player_owned:
		area.destroy()
		hp -= area.hp
		if hp < 0: hp = 0
		hp_changed.emit(hp)
		if hp == 0: destroy()
