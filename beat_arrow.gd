extends Node3D

var beat_index_0_offset = -3.5
var beat_index_size = 1

func move_to_beat_index(beat_index: int):
	transform.origin.x = beat_index_0_offset + beat_index * beat_index_size
