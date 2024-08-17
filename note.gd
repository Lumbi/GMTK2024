extends Node3D

@onready var bass_p1: AudioStream = preload("res://audio/song/GMTK2024-bass-p1.wav")
@onready var bass_p2: AudioStream = preload("res://audio/song/GMTK2024-bass-p2.wav")
@onready var bass_p3: AudioStream = preload("res://audio/song/GMTK2024-bass-p3.wav")
@onready var bass_p4: AudioStream = preload("res://audio/song/GMTK2024-bass-p4.wav")

@onready var synth_a_1: AudioStream = preload("res://audio/song/GMTK2024-synth-a-1.wav")
@onready var synth_a_23: AudioStream = preload("res://audio/song/GMTK2024-synth-a-23.wav")
@onready var synth_a_4: AudioStream = preload("res://audio/song/GMTK2024-synth-a-4.wav")
@onready var synth_a_567: AudioStream = preload("res://audio/song/GMTK2024-synth-a-567.wav")
@onready var synth_a_8: AudioStream = preload("res://audio/song/GMTK2024-synth-a-8.wav")

@export var keyA: StringName
@export var keyB: StringName

func play(loop_index: int) -> void:
	var keyToMatch: StringName
	if loop_index % 2 == 0:
		keyToMatch = keyA
	else:
		keyToMatch = keyB

	match keyToMatch:
		"BASS1": $Audio.stream = bass_p1
		"BASS2": $Audio.stream = bass_p2
		"BASS3": $Audio.stream = bass_p3
		"BASS4": $Audio.stream = bass_p4
		"SYNTHA1": $Audio.stream = synth_a_1
		"SYNTHA2": $Audio.stream = synth_a_23
		"SYNTHA4": $Audio.stream = synth_a_4
		"SYNTHA5": $Audio.stream = synth_a_567
		"SYNTHA8": $Audio.stream = synth_a_8
		_: pass
	$Audio.play()
