extends Node3D

# TODO: Check if audio stream is playing and sync with beat

@export var bpm: float = 50

@onready var beat_arrow: Node3D = get_node("BeatArrow")
var current_hover_block: Node3D
var first_block: bool = true
var queue_spawn_hover_block: bool = false
var next_beat_index: int = 0
var current_loop_index: int = 0
var beat_time: float = 0
var beat_duration: float
var bar_duration: float
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

var is_playing: bool = false
var is_gameover: bool = false
var is_win: bool = false

func _ready() -> void:
	$GameOver.hide()
	
	randomize()
	
	_spawn_hover_block()

 	# BASS
	lane1.get_child(0).spawn_note("BASS1", "BASS3")
	lane0.get_child(4).spawn_note("BASS2", "BASS4")
	
	# SYNTH
	lane2.get_child(0).spawn_note("SYNTHA1", "SYNTHA1")
	lane3.get_child(1).spawn_note("SYNTHA2", "SYNTHA2")
	lane2.get_child(3).spawn_note("SYNTHA4", "SYNTHA4")
	lane3.get_child(4).spawn_note("SYNTHA5", "SYNTHA5")
	lane2.get_child(7).spawn_note("SYNTHA8", "SYNTHA8")
	
	# TEST
	#lane0.get_child(0).spawn_note("C0_2")
	#lane0.get_child(2).spawn_note("C0_3")
	#lane0.get_child(4).spawn_note("C0_4")
	#lane0.get_child(6).spawn_note("C0_4")
	
	#lane1.get_child(1).spawn_note(" C0_4")
	# lane1.get_child(2).spawn_note("C1_2")
	#lane1.get_child(4).spawn_note("C1_3")
	#lane1.get_child(6).spawn_note("C1_2")
	
	pass

var bar_time: float = 0

func _process(delta: float) -> void:
	beat_duration = (1.0 / (bpm * 2.0) * 60.0)
	bar_duration = beat_duration * 8

	#if $BGM.playing:
	#	bar_time += delta
	var bar_time = $BGM.get_playback_position() + AudioServer.get_time_since_last_mix()
	while bar_time > bar_duration:
		bar_time -= bar_duration

	var beat_index: int = floori(bar_time / beat_duration)

	# get_node("UI/Debug").text = "DEBUG: bar_time = %f" % bar_time

	beat_time = bar_time - (beat_index * beat_duration)

	if bar_time >= next_beat_index * beat_duration && bar_time < (next_beat_index + 1) * beat_duration:
		_hit_beat(beat_index)

	if !is_gameover:
		if Input.is_action_just_pressed("drop") && current_hover_block:
			if is_playing && !$AnimationPlayer.is_playing():
				if beat_time < beat_duration * beat_trailing_acceptance_threshold_ratio: # on time
					_try_drop(beat_index)
				elif beat_time > (beat_duration * (1 - beat_leading_acceptance_threshold_ratio)): # a bit early
					_try_drop((beat_index + 1) % 8)
				else:
					$Fail.transform.origin = current_hover_block.transform.origin
					$Fail.transform.origin.z += 0.5
					$Fail.flash()
			else:
				is_playing = true
				$AnimationPlayer.current_animation = "play_start_camera"
				$AnimationPlayer.play()
				$HowTo.hide()

func _try_drop(index: int) -> void:
	if current_hover_block:
		# Find available slot
		var available_slot = _find_available_slot_at_index(index)
		if available_slot:
			current_hover_block.drop(available_slot)
		else:
			current_hover_block.destroy_shrink()
			
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

func _hit_beat(beat_index: int) -> void:
	next_beat_index = (beat_index + 1) % 8
	
	# Move the arrow
	beat_arrow.move_to_beat_index(beat_index)
	
	# Move the hover block
	if current_hover_block:
		current_hover_block.transform.origin = beat_arrow.transform.origin
		current_hover_block.transform.origin.y -= 0.8
	else:
		_spawn_hover_block(true) #queue spawn
		
	# Lane beat	
	for lane in lanes:
		lane.hit_beat(current_loop_index, beat_index)
		
	if (beat_index == 7):
		current_loop_index += 1
		
	# Win / Lose
	if !is_gameover:
		if _all_note_blocks_covered():
			is_gameover = true
			is_win = true
			_play_gameover()
		elif _cannot_place_more_blocks():
			is_gameover = true
			is_win = false
			_play_gameover()

func _spawn_hover_block(queue: bool = false) -> void:
	if is_gameover: return
	
	if queue && !queue_spawn_hover_block:
		queue_spawn_hover_block = true
		return

	if current_hover_block: return

	var note_is_available = _has_available_note()

	var block_scene: PackedScene
	if first_block:
		first_block = false
		block_scene = normal_block_scene
	elif note_is_available && randf() < 0.4:
		block_scene = note_block_scene
	elif randf() < 0.25:
		block_scene = bomb_block_scene
	elif randf() < 0.1:
		block_scene = note_block_scene
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
				var below_lane = lanes[y-1]
				var below_block = below_lane.get_child(x)
				if !below_block.is_empty():
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

func _all_note_blocks_covered() -> bool:
	for x in 8:
		for y in 4:
			var lane = lanes[y]
			var slot = lane.get_child(x)
			if slot.has_note() && slot.is_empty():
				return false
	return true
	
func _cannot_place_more_blocks() -> bool:
	var lane = lanes[3]
	for x in 8:
		var slot = lane.get_child(x)
		if slot.is_empty() || slot.assigned_block.get_meta("type") == "bomb":
			return false
	return true

func _play_gameover() -> void:
	if current_hover_block:
		current_hover_block.hide()
	$BeatArrow.hide()
	if is_win:
		$GameOver.text = "Thank you for playing"
	else:
		$GameOver.text = "Game Over"	
	$AnimationPlayer.current_animation = "gameover"
	$AnimationPlayer.play()
