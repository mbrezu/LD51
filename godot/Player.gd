extends Spatial

signal new_position
signal food_collected
signal died

var x = 0
var y = 0
var px = 0
var py = 0
var action_forward
var action_backward
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

	process_current_movement(delta)

	if translation == target_position:
		decide_future_movement()


func process_current_movement(delta):
	if action_backward != null and Input.is_action_pressed(action_backward):
		var aux = px
		px = x
		x = aux
		aux = py
		py = y
		y = aux
		aux = action_backward
		action_backward = action_forward
		action_forward = aux
		set_player_position()

	if true: #action_forward != null and Input.is_action_pressed(action_forward):
		var direction = (target_position - translation).normalized()
		var difference = target_position - translation
		var movement = direction * delta * speed
		if movement.length() >= difference.length():
			translation = target_position
		else:
			translation += movement


func decide_future_movement():
	# print_debug("aligned")
	var cell = maze.cells[x][y]

	# We might have multiple keys pressed.
	var velocities = []

	if Input.is_action_pressed("ui_left") and (!cell.has_left_wall or can_go_through_walls):
		velocities.push_back([Vector2.LEFT, "ui_left"])
	if Input.is_action_pressed("ui_right") and (!cell.has_right_wall or can_go_through_walls):
		velocities.push_back([Vector2.RIGHT, "ui_right"])
	if Input.is_action_pressed("ui_up") and (!cell.has_top_wall or can_go_through_walls):
		velocities.push_back([Vector2.UP, "ui_up"])
	if Input.is_action_pressed("ui_down") and (!cell.has_bottom_wall or can_go_through_walls):
		velocities.push_back([Vector2.DOWN, "ui_down"])

#	if !velocities.empty():
		#print_debug("alternatives")
		# for v in velocities:
		# 	print_debug(v[0], " ", v[1])

	# By default we don't move.
	var velocity = Vector2.ZERO

	# If there is any arrow key pressed, move in that direction.
	if !velocities.empty():
		velocity = velocities[0][0]

	# If there is any arrow key pressed OTHER than current
	# forward and backward keys, pick that one.
	for v in velocities:
		if v[1] != action_backward and v[1] != action_forward:
			velocity = v[0]

	action_forward = null
	action_backward = null

	if velocity != Vector2.ZERO:

		if velocity == Vector2.LEFT:
			action_forward = "ui_left"
			action_backward = "ui_right"
		elif velocity == Vector2.RIGHT:
			action_forward = "ui_right"
			action_backward = "ui_left"
		elif velocity == Vector2.UP:
			action_forward = "ui_up"
			action_backward = "ui_down"
		elif velocity == Vector2.DOWN:
			action_forward = "ui_down"
			action_backward = "ui_up"

		# print_debug("decided on ", velocity)

		if velocity.x < 0:
			$Body.rotation = face_up_rotation
			$Body.rotate(Vector3.UP, PI / 2)
			px = x
			py = y
			x -= 1

		if velocity.x > 0:
			$Body.rotation = face_up_rotation
			$Body.rotate(Vector3.UP, -PI / 2)
			px = x
			py = y
			x += 1

		if velocity.y < 0:
			$Body.rotation = face_up_rotation
			px = x
			py = y
			y -= 1

		if velocity.y > 0:
			$Body.rotation = face_up_rotation
			$Body.rotate(Vector3.UP, PI)
			px = x
			py = y
			y += 1

		x = clamp(x, 0, maze.cells.size() - 1)
		y = clamp(y, 0, maze.cells.size() - 1)
		set_player_position()


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
