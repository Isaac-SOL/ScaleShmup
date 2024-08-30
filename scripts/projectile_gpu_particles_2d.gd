extends GPUParticles2D

func _process(_delta):
	process_material.scale_min = self.scale.x
	process_material.scale_min = self.scale.y
	process_material.angle_min = rad_to_deg(- self.rotation - %Sprite2D.rotation)
	process_material.angle_max = rad_to_deg(- self.rotation - %Sprite2D.rotation)
	
