extends Area


var x
var y
var maze
var target_position = Vector3.ZERO
var speed = 1
var player_distances


func initialize(px, py, pmaze):
	x = px
	y = py
	maze = pmaze
	set_enemy_position()
	translation = target_position


func set_enemy_position():
	target_position = Vector3(x - maze.cells.size() / 2, 0, y - maze.cells.size() / 2)


func new_player_position(distances):
	player_distances = distances


func _negate_all(distances):
	var result = []
	for i in range(distances.size()):
		var column = []
		for j in range(distances.size()):
			column.append(-distances[i][j])
		result.append(column)
	return result


func _process(delta):
	if (translation - target_position).length() < 0.1:
		translation = target_position

	if (translation == target_position):
		if player_distances == null:
			return
		var distance_here = player_distances[x][y]
		var distances = player_distances
		if randf() < .25: # 25% chances to run away this turn
			distance_here = -distance_here
			distances = _negate_all(player_distances)

		var candidates = []
		if !maze.cells[x][y].has_top_wall and distances[x][y - 1] < distance_here:
			candidates.append([0, -1])
		if !maze.cells[x][y].has_bottom_wall and distances[x][y + 1] < distance_here:
			candidates.append([0, 1])
		if !maze.cells[x][y].has_left_wall and distances[x - 1][y] < distance_here:
			candidates.append([-1, 0])
		if !maze.cells[x][y].has_right_wall and distances[x + 1][y] < distance_here:
			candidates.append([1, 0])
		if candidates.size() > 0:
			var direction = candidates[randi() % candidates.size()]
			x += direction[0]
			y += direction[1]
			set_enemy_position()
	else:
		var direction = (target_position - translation).normalized()
		translation += direction * delta * speed
