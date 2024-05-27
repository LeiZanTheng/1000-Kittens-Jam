class_name NerdCat
extends Area2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var pop_sfx: AudioStreamPlayer = $PopSFX

# Drag and click variables
var can_dragged : bool = false
var can_merge : bool = false
var is_touched : bool = false # Check if mouse is touching the collsion shape
var is_target : bool = false
var out_of_bound : bool = false

# Random stuff
var found_target : bool = false
var merge_target : NerdCat = null
var allow_patrol : bool = true
var tween : Tween
var is_merging : bool = false
var target_list : Array
var allow_meow : bool = true

# Entity's statistic
var merge_speed : float = 0.15
var puff_size : float = 0.25
var patrol_range : float = 50
var patrol_time_speed : float = 0.5
var time_btw_patrol : float = 1.3

func _process(_delta: float) -> void:
	# Keep these cat in bound
	global_position.x = clamp(global_position.x, 0 + 100, get_viewport().content_scale_size.x - 100)
	global_position.y = clamp(global_position.y, 0 + 100, get_viewport().content_scale_size.y - 100)
	
	# Allow merge if target is the same class, haven't found any other target yet and this entity is being dragged by player
	# Allow merge if target isn't tagged or merged by other entity
	for current_target in target_list:
		if not found_target and can_dragged:
			if not current_target.is_target and not current_target.can_merge:
				can_merge = true
				found_target = true
				merge_target = current_target
				merge_target.is_target = true
	
	# Perform drag, if not then go around
	if can_dragged and Input.is_action_pressed("mouse_press") and not is_merging:
		if tween != null:
			tween.kill() # Stop all animtion or progress to drag the entity (except merging anim) 
		global_position = get_global_mouse_position()
		if allow_meow:
			allow_meow = false
			audio_stream_player.play()
	elif allow_patrol:
		allow_meow = true
		_patrol()

	# Increase entity size if found merge target or is target itself
	if can_merge or is_target:
		_puff()
	else:
		_unpuff()

	# Perform merge
	if can_merge and Input.is_action_just_released("mouse_press"):
		can_dragged = false
		Global.mouse_occupied = false
		_merge()

# Detect dragging stuff
func _on_mouse_entered() -> void:
	is_touched = true
	if not Global.mouse_occupied and not is_merging:
		can_dragged = true
		Global.mouse_occupied = true

func _on_mouse_exited() -> void:
	is_touched = false
	if not Input.is_action_pressed("mouse_press") and can_dragged:
		can_dragged = false
		Global.mouse_occupied = false

# Detect merge target
func _on_area_entered(area: Area2D) -> void:
	if area is NerdCat:
		target_list.append(area)
	
func _on_area_exited(area: Area2D) -> void:
	target_list.erase(area)
	# Target exits entity area
	if area == merge_target:
		found_target = false
		can_merge = false
		merge_target.is_target = false
		merge_target = null

func _puff() -> void:
	global_scale = Vector2(1 + puff_size, 1 + puff_size)

func _unpuff() -> void:
	global_scale = Vector2(1, 1)

func _merge() -> void:
	is_merging = true
	pop_sfx.play()
	var merge_position := Vector2((global_position.x + merge_target.global_position.x) / 2.0, (global_position.y + merge_target.global_position.y) / 2.0)
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_position", merge_position, merge_speed)
	tween.tween_property(merge_target, "global_position", merge_position, merge_speed)
	await tween.finished
	Global.mouse_occupied = false
	if merge_target != null : merge_target.queue_free()
	self.queue_free()
	_spawn_new_cat(merge_position)

func _spawn_new_cat(spawn_pos : Vector2) -> void:
	const NEXT_CAT := preload("res://Scenes/Entities/wizard_cat.tscn")
	var cur_cat := NEXT_CAT.instantiate()
	cur_cat.position = spawn_pos
	get_parent().add_child(cur_cat)

func _patrol() -> void:
	allow_patrol = false
	var patrol_destination : Vector2
	patrol_destination.x = clamp(global_position.x + [-patrol_range, patrol_range].pick_random(), 0 + 100, get_viewport().content_scale_size.x - 100)
	patrol_destination.y = clamp(global_position.y + [-patrol_range, patrol_range].pick_random(), 0 + 100, get_viewport().content_scale_size.y - 100)
	tween = create_tween()
	tween.tween_property(self, "global_position", patrol_destination, patrol_time_speed).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(time_btw_patrol).timeout
	allow_patrol = true
