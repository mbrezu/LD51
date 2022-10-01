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
		if velocity.x < 0 and !cell.has_left_wall:
			x -= 1
		if velocity.x > 0 and !cell.has_right_wall:
			x += 1
		if velocity.y < 0 and !cell.has_top_wall:
			y -= 1
		if velocity.y > 0 and !cell.has_bottom_wall:
			y += 1
		set_player_position()

	var direction = (targetPosition - translation).normalized()
	translation += direction * delta * speed