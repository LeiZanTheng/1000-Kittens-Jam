extends Marker2D
var time_between_spawn : float = 1
var allow_spawn : bool = true
func _process(_delta: float) -> void:
	if allow_spawn:
		_spawn_cat()

func _spawn_cat() -> void:
	allow_spawn = false
	const TARGET_CAT := preload("res://Scenes/Entities/orange_cat.tscn")
	var current_cat := TARGET_CAT.instantiate()
	current_cat.position = global_position
	get_parent().add_child(current_cat)
	await get_tree().create_timer(time_between_spawn).timeout
	allow_spawn = true
