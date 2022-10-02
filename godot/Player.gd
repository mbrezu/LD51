extends Spatial

signal new_position
signal food_collected
signal died

var x = 0
var y = 0
var maze = maze
var velocity = Vector2.ZERO
var target_position = Vector3.ZERO
var speed = 3
var face_up_rotation
var alive = true


func _ready():
	face_up_rotation = $Body.rotation


func initialize(pmaze):
	x = floor(pmaze.cells.size() / 2)
	y = floor(pmaze.cells.size() / 2)
	maze = pmaze
	set_player_position()


func set_player_position():
	emit_signal("new_position", maze.get_distances_from(x, y), x, y)
	target_position = Vector3(x - maze.cells.size() / 2, 0, y - maze.cells.size() / 2)


func zoom_in():
	$Camera.zoom_in()


func zoom_out():
	$Camera.zoom_out()


func set_normal_speed():
	speed = 3


func set_fast_speed():
	speed = 6


func _process(delta):
	if !alive:
		return

	if (translation - target_position).length() < 0.1:
		translation = target_position

	if Input.is_action_pressed("ui_left"):
		velocity = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		velocity = Vector2.RIGHT
	elif Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN

	if translation == target_position and velocity != Vector2.ZERO:
		var cell = maze.cells[x][y]
		if velocity.x < 0 and !cell.has_left_wall:
			x -= 1
			$Body.rotation = face_up_rotation
			$Body.rotate(Vector3.UP, PI / 2)
		if velocity.x > 0 and !cell.has_right_wall:
			x += 1
			$Body.rotation = face_up_rotation
			$Body.rotate(Vector3.UP, -PI / 2)
		if velocity.y < 0 and !cell.has_top_wall:
			y -= 1
			$Body.rotation = face_up_rotation
		if velocity.y > 0 and !cell.has_bottom_wall:
			y += 1
			$Body.rotation = face_up_rotation
			$Body.rotate(Vector3.UP, PI)
		set_player_position()

	var direction = (target_position - translation).normalized()
	translation += direction * delta * speed


func _on_Area_area_entered(area):
	if area.is_in_group("enemy") and alive:
		alive = false
		$AnimationPlayer.play("Death")
		emit_signal("died")
	if area.is_in_group("food"):
		emit_signal("food_collected")
		area.collect()


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == "Death":
		$Body.queue_free()
