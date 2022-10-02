extends Position3D


func zoom_in():
	$AnimationPlayer.queue("zoom_in")


func zoom_out():
	$AnimationPlayer.queue("zoom_out")


func shake():
	if randf() < 0.5:
		$AnimationPlayer.queue("shake_x")
	else:
		$AnimationPlayer.queue("shake_y")