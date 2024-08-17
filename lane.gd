extends Node3D

func hit_beat(index: int) -> void:
	var slot: Node3D = get_child(index)
	slot.hit_beat()
