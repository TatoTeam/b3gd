class_name Receptor extends Resource

@export var notes: Array[Note]

class ReceptorInput extends RefCounted:
	## The time the input occured. Used for rendering
	@export var input_time: float = -1000.0
	## If drawing this press should be ignored. For when an input is released
	@export var ignore_draw: bool = true
	## This is "true" when the input didnt hit any notes.
	@export var dummy: bool = false

var last_press:ReceptorInput

func sort_notes():
	notes.sort_custom(func(a: Note, b: Note): return a.time < b.time)
