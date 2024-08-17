extends Node3D

@onready var C0_1: AudioStream = preload("res://audio/C0_1.wav")
@onready var C0_2: AudioStream = preload("res://audio/C0_2.wav")
@onready var C0_3: AudioStream = preload("res://audio/C0_3.wav")
@onready var C0_4: AudioStream = preload("res://audio/C0_4.wav")
@onready var C1_1: AudioStream = preload("res://audio/C1_1.wav")
@onready var C1_2: AudioStream = preload("res://audio/C1_2.wav")
@onready var C1_3: AudioStream = preload("res://audio/C1_3.wav")
@onready var C1_4: AudioStream = preload("res://audio/C1_4.wav")
@onready var C2_1: AudioStream = preload("res://audio/C2_1.wav")

@export var key: StringName = "C1_1"

func play() -> void:
	match key:
		"C0_1": $Audio.stream = C0_1
		"C0_2": $Audio.stream = C0_2
		"C0_3": $Audio.stream = C0_3
		"C0_4": $Audio.stream = C0_4
		"C1_1": $Audio.stream = C1_1
		"C1_2": $Audio.stream = C1_2
		"C1_3": $Audio.stream = C1_3
		"C1_4": $Audio.stream = C1_4
		"C2_1": $Audio.stream = C2_1
		_: pass
	$Audio.play()
