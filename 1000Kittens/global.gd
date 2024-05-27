extends Node

var mouse_occupied : bool = false # Check if player is dragging anything

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_G):
		mouse_occupied = false
