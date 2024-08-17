extends Node3D

var assigned_block: Node3D
var note: Node3D
@onready var note_scene: PackedScene = load("res://note.tscn")

func is_empty() -> bool:
	return assigned_block == null
	
func spawn_note() -> void:
	note = note_scene.instantiate()
	add_child(note)

func hit_beat() -> void:
	$AnimationPlayer.current_animation = "slot_beat_anim"
	$AnimationPlayer.play()
	
	if note && assigned_block:
		note.play()

func accept(block: Node3D) -> void:
	match block.get_meta("type"):
		"note":
			if note:
				_force_accept(block)
				note.hide()
			else:
				block.queue_free()
		_:
			_force_accept(block)
			
	

func _force_accept(block: Node3D) -> void:
	assigned_block = block
	var keep_global_transform = true
	assigned_block.reparent(self, keep_global_transform)
	assigned_block.transform.origin = Vector3.ZERO
