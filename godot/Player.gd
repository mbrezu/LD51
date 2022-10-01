extends Spatial

var x = 0
var y = 0
var maze = maze
var velocity = Vector2.ZERO
var targetPosition = Vector3.ZERO
var speed = 5


func initialize(pmaze):
	x = floor(pmaze.cells.size() / 2)
	y = floor(pmaze.cells.size() / 2)
	maze = pmaze
	set_player_position()


func set_player_position():
	targetPosition = Vector3(x - maze.cells.size() / 2, 0, y - maze.cells.size() / 2)
	var cell = maze.cells[x][y]
	print_debug("***")
	print_debug("top: %s bottom: %s left: %s right: %s" % [cell.has_top_wall, cell.has_bottom_wall, cell.has_left_wall, cell.has_right_wall])


func _process(delta):
	if (translation - targetPosition).length() < 0.1:
		translation = targetPosition

	if Input.is_action_pressed("ui_left"):
		velocity = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		velocity = Vector2.RIGHT
	elif Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN

	if translation == targetPosition and velocity != Vector2.ZERO:
		var cell = maze.cells[x][y]
		print_debug(velocity, x, " ", y)
		if velocity.x < 0 and !cell.has_left_wall:
			x -= 1
		if velocity.x > 0 and !cell.has_right_wall:
			x += 1
		if velocity.y < 0 and !cell.has_top_wall:
			print_debug("going up")
			y -= 1
		if velocity.y > 0 and !cell.has_bottom_wall:
			print_debug("going down")
			y += 1
		print_debug(x, " ", y)
		set_player_position()

	var direction = (targetPosition - translation).normalized()
	translation += direction * delta * speed