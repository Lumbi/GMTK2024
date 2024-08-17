extends Node3D

var lane_index: int
var index: int
var assigned_block: Node3D
var note: Node3D
@onready var note_scene: PackedScene = load("res://note.tscn")

func is_empty() -> bool:
	return assigned_block == null
	
func has_note() -> bool:
	return note != null
	
func spawn_note(keyA: StringName, keyB: StringName) -> void:
	note = note_scene.instantiate()
	note.keyA = keyA
	note.keyB = keyB
	add_child(note)

func hit_beat(loop_index: int) -> void:
	$AnimationPlayer.current_animation = "slot_beat_anim"
	$AnimationPlayer.play()
	
	if assigned_block:
		if note && assigned_block.get_meta("type") == "note":
			note.play(loop_index)
		else:
			match assigned_block.get_meta("type"):
				"bomb": _bomb_blow_around()
				_: pass

func accept(block: Node3D) -> void:
	match block.get_meta("type"):
		"note":
			if note:
				_force_accept(block)
				note.hide()
			else:
				block.destroy_shrink()
		_:
			if !note:
				_force_accept(block)
			else:
				block.destroy_shrink()

# Clears the assigned block
func clear() -> void:
	if assigned_block:
		assigned_block.destroy_shrink()
		assigned_block = null

	if note:
		note.show()

func _force_accept(block: Node3D) -> void:
	assigned_block = block
	var keep_global_transform = true
	assigned_block.reparent(self, keep_global_transform)
	assigned_block.transform.origin = Vector3.ZERO

func _bomb_blow_around() -> void:
	# destroy up/left/down/right
	var lanes = get_tree().root.get_node("root/Lanes")
	for d in [-1, 1]:
		var x1 = index + d
		var y1 = lane_index
		if x1 >= 0 && x1 < 8 && y1 >= 0 && y1 < 4:
			var l = lanes.get_child(y1)
			var s = l.get_child(x1)
			s.clear()

		var x2 = index
		var y2 = lane_index + d
		if x2 >= 0 && x2 < 8 && y2 >= 0 && y2 < 4:
			var l = lanes.get_child(y2)
			var s = l.get_child(x2)
			s.clear()

	# destroy own block
	clear()
