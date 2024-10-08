extends Node3D

const STATE_HOVER: int = 0
const STATE_DROP: int = 1
const STATE_PLACED: int = 2
const STATE_DESTROY: int = 3
var state: int = STATE_HOVER

const DROP_DURATION = 0.2
var drop_start_position: Vector3
var drop_end_position: Vector3
var drop_time = 0

var target_drop_slot: Node3D

var until_destroy_time: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		STATE_HOVER:
			pass
		STATE_DROP:
			drop_time += delta
			if drop_time <= DROP_DURATION:
				transform.origin = lerp(drop_start_position, drop_end_position, clamp(drop_time / DROP_DURATION, 0 ,1))
			else:
				state = STATE_PLACED
				target_drop_slot.accept(self)
			pass
		STATE_DESTROY:
			
			until_destroy_time -= delta
			if until_destroy_time <= 0:
				queue_free()
			pass
		_:
			pass
	pass

func drop(slot: Node3D) -> void:
	target_drop_slot = slot
	drop_start_position = transform.origin
	drop_start_position.x = slot.global_position.x
	drop_end_position = slot.global_position
	drop_time = 0
	state = STATE_DROP
	pass

func hit_beat() -> void:
	if get_meta("type") == "note":
		$AnimationPlayer.current_animation = "bounce"
		$AnimationPlayer.play()

func destroy_shrink() -> void:
	$AnimationPlayer.current_animation = "block_destroy_shrink"
	$AnimationPlayer.play()
	state = STATE_DESTROY
