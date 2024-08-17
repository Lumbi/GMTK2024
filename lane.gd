extends Node3D

@export var index: int

func _ready() -> void:
	for x in 8:
		var slot = get_child(x)
		slot.index = x
		slot.lane_index = index

func hit_beat(index: int) -> void:
	var slot: Node3D = get_child(index)
	slot.hit_beat()
