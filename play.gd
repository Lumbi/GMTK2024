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

@onready var note_block_scene: PackedScene = load("res://block_note.tscn")
@onready var normal_block_scene: PackedScene = load("res://block_normal.tscn")
@onready var bomb_block_scene: PackedScene = load("res://block_bomb.tscn")

@onready var lane0: Node3D = get_node("Lanes/Lane0")
@onready var lane1: Node3D = get_node("Lanes/Lane1")
@onready var lane2: Node3D = get_node("Lanes/Lane2")
@onready var lane3: Node3D = get_node("Lanes/Lane3")
@onready var lanes: Array = [lane0, lane1, lane2, lane3]

func _ready() -> void:
	randomize()
	
	_spawn_hover_block()
	
	# TEST
	# lane0.get_child(0).spawn_note()
	lane2.get_child(2).spawn_note()
	lane3.get_child(4).spawn_note()
	
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
	var last_empty_slot: Node3D
	for y in [3, 2, 1, 0]:
		var slot = lanes[y].get_child(index)
		if slot.is_empty():
			last_empty_slot = slot
		else:
			break
	return last_empty_slot

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

	var note_is_available = _has_available_note()
	print("note_is_available ", note_is_available)
	
	var block_scene: PackedScene
	var random = randf()
	if note_is_available && random > 0.5:
		block_scene = note_block_scene
	elif random < 0.1:
		block_scene = bomb_block_scene
	else:
		block_scene = normal_block_scene

	current_hover_block = block_scene.instantiate()
	current_hover_block.transform.origin = beat_arrow.transform.origin
	current_hover_block.transform.origin.y -= 0.8
	add_child(current_hover_block)
	
	queue_spawn_hover_block = false

func _has_available_note() -> bool:
	for x in 8:
		for y in 4:
			var lane = lanes[y]
			var slot = lane.get_child(x)
			if slot.has_note() && slot.is_empty():
				if y == 0:
					return true # exit early if on bottom lane
				var below_slots_all_occupied = true
				for by in range(y-1, 0, -1):
					var below_lane = lanes[by]
					var below_block = below_lane.get_child(x)
					if below_block.is_empty():
						below_slots_all_occupied = false
						break
				if below_slots_all_occupied:
					return true
	return false

# NOT SURE IF I WANT THIS
func _drop_blocks_in_slots() -> void:
	for x in 8:
		for y in 4:
			var y_below = y -1
			if y_below >=0:
				var lane = lanes[y]
				var slot = lane.get_child(x)
				var lane_below = lanes[y_below]
				var slot_below = lane_below.get_child(x)
				if !slot.is_empty() && slot_below.is_empty():
					slot.assigned_block.drop(slot_below)
					slot_below.accept(slot.assigned_block)
