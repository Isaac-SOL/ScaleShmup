extends Projectile

@export var rotation_speed: float = TAU
@export var sprites: Array[Texture2D]

func _ready():
	super._ready()
	%Sprite2D.texture = sprites.pick_random()

func _process(delta):
	%Sprite2D.rotation += rotation_speed * delta
