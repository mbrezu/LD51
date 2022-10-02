extends Position3D


func zoom_in():
	$AnimationPlayer.queue("zoom_in")


func zoom_out():
	$AnimationPlayer.queue("zoom_out")


