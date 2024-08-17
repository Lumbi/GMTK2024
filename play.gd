extends Node3D

@export var bpm: float = 50

@onready var beat_arrow: Node3D = get_node("BeatArrow")
var current_hover_block: Node3D
var queue_spawn_hover_block: bool = false
var current_beat_index: int = 0
var beat_time: float = 0
var beat_duration: float
var beat_leading_acceptance_threshold_ratio: float = 0.20
var beat_trailing_acceptance_threshold_ratio: float = 0.20

@onready var all_block_scenes: Array = [
	load("res://block_note.tscn"), 
	load("res://block_normal.tscn")
]

@onready var lane0: Node3D = get_node("Lanes/Lane0")
@onready var lane1: Node3D = get_node("Lanes/Lane1")
@onready var lane2: Node3D = get_node("Lanes/Lane2")
@onready var lane3: Node3D = get_node("Lanes/Lane3")
@onready var lane4: Node3D = get_node("Lanes/Lane4")
@onready var lanes: Array = [lane0, lane1, lane2, lane3, lane4]

func _ready() -> void:
	_spawn_hover_block()
	_hit_beat()
	
	# TEST
	lane0.get_child(0).spawn_note()
	lane2.get_child(2).spawn_note()
	lane4.get_child(4).spawn_note()
	
	pass

func _process(delta: float) -> void:
	beat_time += delta
	beat_duration = (1.0 / (bpm * 2.0) * 60.0)
	if (beat_time >= beat_duration):
		beat_time = 0
		_hit_beat()

	if Input.is_action_just_pressed("drop"):
		if beat_time < beat_duration * beat_trailing_acceptance_threshold_ratio: # on time
			_try_drop(current_beat_index)
		elif beat_time > (beat_duration * (1 - beat_leading_acceptance_threshold_ratio)): # a bit early
			_try_drop((current_beat_index + 1) % 8)

func _try_drop(index: int) -> void:
	if current_hover_block:
		# Find available slot
		var available_slot = _find_available_slot_at_index(index)
		if available_slot:
			current_hover_block.drop(available_slot)
			current_hover_block = null
	
func _find_available_slot_at_index(index: int) -> Node3D:
	for lane in lanes:
		var slot = lane.get_child(index)
		if slot.is_empty():
			return slot
	return null

func _hit_beat() -> void:
	current_beat_index += 1
	if (current_beat_index >= 8):
		current_beat_index = 0

	# Move the arrow
	beat_arrow.move_to_beat_index(current_beat_index)
	
	# Move the hover block
	if current_hover_block:
		current_hover_block.transform.origin = beat_arrow.transform.origin
		current_hover_block.transform.origin.y -= 0.8
	else:
		_spawn_hover_block(true) #queue spawn
		
	# Lane beat	
	for lane in lanes:
		lane.hit_beat(current_beat_index)

func _spawn_hover_block(queue: bool = false) -> void:
	if queue && !queue_spawn_hover_block:
		queue_spawn_hover_block = true
		return

	if current_hover_block: return

	var block_scene: PackedScene = all_block_scenes.pick_random()
	current_hover_block = block_scene.instantiate()
	current_hover_block.transform.origin = beat_arrow.transform.origin
	current_hover_block.transform.origin.y -= 0.8
	add_child(current_hover_block)
	
	queue_spawn_hover_block = false
