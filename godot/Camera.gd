extends Position3D

var animation_queue = []
var animation_in_progress = false


func zoom_in():
	queue_animation("zoom_in")


func zoom_out():
	queue_animation("zoom_out")


func queue_animation(animation_name):
	if !animation_queue.empty() or animation_in_progress:
		animation_queue.push_back(animation_name)
	else:
		animation_in_progress = true
		$AnimationPlayer.play(animation_name)


func _on_AnimationPlayer_animation_finished(_anim_name:String):
	animation_in_progress = false
	if !animation_queue.empty():
		animation_in_progress = true
		$AnimationPlayer.play(animation_queue.pop_front())
