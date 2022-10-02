extends Spatial

signal new_position
signal food_collected
signal died

var x = 0
var y = 0
var maze = maze
var target_position = Vector3.ZERO
var speed = 3
var face_up_rotation
var alive = true
var can_go_through_walls = false
var food_is_poison = false
var hunt_enemies = false

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


func shake():
	$Camera.shake()


func set_normal_speed():
	speed = 3


func set_fast_speed():
	speed = 6


func set_slow_speed():
	speed = 1.5


func _process(delta):
	if !alive:
		return

	if (translation - target_position).length() < 0.1:
		translation = target_position

	if translation == target_position:
		var velocity = Vector2.ZERO

		if Input.is_action_pressed("ui_left"):
			velocity = Vector2.LEFT
		elif Input.is_action_pressed("ui_right"):
			velocity = Vector2.RIGHT
		elif Input.is_action_pressed("ui_up"):
			velocity = Vector2.UP
		elif Input.is_action_pressed("ui_down"):
			velocity = Vector2.DOWN

		if velocity != Vector2.ZERO:
			var cell = maze.cells[x][y]

			if velocity.x < 0:
				$Body.rotation = face_up_rotation
				$Body.rotate(Vector3.UP, PI / 2)
				if !cell.has_left_wall or can_go_through_walls:
					x -= 1

			if velocity.x > 0:
				$Body.rotation = face_up_rotation
				$Body.rotate(Vector3.UP, -PI / 2)
				if !cell.has_right_wall or can_go_through_walls:
					x += 1

			if velocity.y < 0:
				$Body.rotation = face_up_rotation
				if !cell.has_top_wall or can_go_through_walls:
					y -= 1

			if velocity.y > 0:
				$Body.rotation = face_up_rotation
				$Body.rotate(Vector3.UP, PI)
				if !cell.has_bottom_wall or can_go_through_walls:
					y += 1

			x = clamp(x, 0, maze.cells.size() - 1)
			y = clamp(y, 0, maze.cells.size() - 1)
			set_player_position()

	var direction = (target_position - translation).normalized()
	translation += direction * delta * speed


func _on_Area_area_entered(area):
	if !alive:
		return
	if area.is_in_group("enemy"):
		if hunt_enemies:
			area.kill()
			for _i in range(5):
				emit_signal("food_collected")
		else:
			kill()
	if area.is_in_group("food"):
		if food_is_poison:
			kill()
		else:
			emit_signal("food_collected")
			area.collect()


func kill():
	alive = false
	$AnimationPlayer.play("Death")
	emit_signal("died")


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == "Death":
		$Body.queue_free()
