class_name OrangeCat
extends Area2D

# Drag and click variables
var can_dragged : bool = false
var can_merge : bool = false
var is_touched : bool = false # Check if mouse is touching the collsion shape

var found_target : bool = false
var merge_target : Area2D = null

func _process(delta: float) -> void:
	
	# Perform drag
	if can_dragged and Input.is_action_pressed("mouse_press"):
		global_position = get_global_mouse_position()
	
	if can_merge:
		global_scale = Vector2(2, 2)
	else:
		global_scale = Vector2(1, 1)

	# Perform merge
	if can_merge and Input.is_action_just_released("mouse_press"):
		merge()
	
func _on_mouse_shape_entered(shape_idx: int) -> void:
	is_touched = true
	if not Global.mouse_occupied:
		can_dragged = true
		Global.mouse_occupied = true

func _on_mouse_shape_exited(shape_idx: int) -> void:
	is_touched = false
	if not Input.is_action_pressed("mouse_press") and can_dragged:
		can_dragged = false
		Global.mouse_occupied = false

func _on_area_entered(area: Area2D) -> void:
	if area is OrangeCat and not found_target:
		can_merge = true
		found_target = true
		merge_target = area
		
func _on_area_exited(area: Area2D) -> void:
	if area == merge_target:
		can_merge = false
		merge_target = null

func merge():
	print("merge")
