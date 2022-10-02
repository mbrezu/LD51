extends Area


func initialize(x, y, maze):
	translation = Vector3(x - maze.cells.size() / 2, 0, y - maze.cells.size() / 2)


func collect():
	$AnimationPlayer.play("going_away")
	remove_from_group("food")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "going_away":
		queue_free()
