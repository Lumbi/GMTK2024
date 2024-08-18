extends Node3D

func _ready() -> void:
	hide()

func flash() -> void:
	show()
	$AnimationPlayer.current_animation = "flash"
	$AnimationPlayer.play()
