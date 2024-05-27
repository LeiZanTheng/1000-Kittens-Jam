extends Marker2D

var time_between_spawn : float = 0.9
var allow_spawn : bool = true
var limit_exceed : bool = false
var cat_spawn_limit : int = 100

func _process(_delta: float) -> void:
	limit_exceed = false
	if get_parent().get_child_count() - 2 > cat_spawn_limit:
		limit_exceed = true
	if allow_spawn and not limit_exceed:
		_spawn_cat()

func _spawn_cat() -> void:
	allow_spawn = false
	var spawn_pos : Vector2
	spawn_pos.x = randf_range(0 + 100, get_viewport().content_scale_size.x - 100)
	spawn_pos.y = randf_range(0 + 100, get_viewport().content_scale_size.y - 100)
	const TARGET_CAT := preload("res://Scenes/Entities/orange_cat.tscn")
	var current_cat := TARGET_CAT.instantiate()
	current_cat.position = spawn_pos
	get_parent().add_child(current_cat)
	await get_tree().create_timer(time_between_spawn).timeout
	allow_spawn = true
