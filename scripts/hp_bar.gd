class_name HPBar extends Node2D

func set_ratio(ratio: float):
	%Foreground.scale.x = ratio
	%Foreground.position.x = -0.5 + (ratio / 2)
