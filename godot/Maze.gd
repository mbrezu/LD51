extends Object


var CellData = preload("res://CellData.gd")


var cells = []


func _init(size):
	cells = _generate_maze(size)


func get_distances_from(x, y):
	return _distances_from(cells, x, y)


func _generate_maze(size):
	var maze = _generate_cells(size)
	var counter = 1
	for column in maze:
		for j in range(size):
			var cell = CellData.new(counter)
			counter += 1
			column[j] = cell
	while _has_multiple_areas(maze):
		_unite_two_random_areas(maze)
	_tear_down_near_border_walls(maze)
	_tear_down_random_walls(maze)
	return maze


func _tear_down_near_border_walls(maze):
	var size = maze.size()
	maze[0][0].has_bottom_wall = false
	maze[0][0].has_right_wall = false
	maze[0][size - 1].has_top_wall = false
	maze[0][size - 1].has_right_wall = false
	maze[size - 1][0].has_left_wall = false
	maze[size - 1][0].has_bottom_wall = false
	maze[size - 1][size - 1].has_left_wall = false
	maze[size - 1][size - 1].has_top_wall = false
	for i in range(1, size - 1):
		var cell_left = maze[0][i]
		cell_left.has_top_wall = false
		cell_left.has_bottom_wall = false
		var cell_right = maze[size - 1][i]
		cell_right.has_top_wall = false
		cell_right.has_bottom_wall = false
		var cell_top = maze[i][0]
		cell_top.has_left_wall = false
		cell_top.has_right_wall = false
		var cell_bottom = maze[i][size - 1]
		cell_bottom.has_left_wall = false
		cell_bottom.has_right_wall = false


func _tear_down_random_walls(maze):
	var max_dist = 10
	var min_dist = 3 # 3 does nothing, 4 is too much
	for i in range(1, maze.size() - 1):
		for j in range(1, maze.size() - 1):
			# print_debug(i, " ", j, " ", maze.size())
			var distances = _distances_from(maze, i, j)
			var cell = maze[i][j]
			if cell.has_left_wall and (distances[i - 1][j] > max_dist or distances[i - 1][j] < min_dist):
				cell.has_left_wall = false
				maze[i - 1][j].has_right_wall = false
			if cell.has_right_wall and (distances[i + 1][j] > max_dist or distances[i + 1][j] < min_dist):
				cell.has_right_wall = false
				maze[i + 1][j].has_left_wall = false
			if cell.has_top_wall and (distances[i][j - 1] > max_dist or distances[i][j - 1] < min_dist):
				cell.has_top_wall = false
				maze[i][j - 1].has_bottom_wall = false
			if cell.has_bottom_wall and (distances[i][j + 1] > max_dist or distances[i][j + 1] < min_dist):
				cell.has_bottom_wall = false
				maze[i][j + 1].has_top_wall = false


func _generate_cells(size):
	var result = []
	for _i in range(size):
		var column = []
		for _j in range(size):
			column.append(null)
		result.append(column)
	return result


func _has_multiple_areas(maze):
	var areas = []
	for column in maze:
		for cell in column:
			var index = areas.find(cell.area)
			if index == -1:
				areas.append(cell.area)
				if areas.size() > 1:
					return true
	return false


func _unite_two_random_areas(maze):
	var size = maze.size()
	var walls_to_break = []
	for i in range(size):
		for j in range(size):
			var cell = maze[i][j]
			if j < size - 1:
				var cell_below = maze[i][j+1]
				if cell.area != cell_below.area:
					walls_to_break.append([[i, j], [i, j + 1]])
			if i < size - 1:
				var cell_right = maze[i + 1][j]
				if cell.area != cell_right.area:
					walls_to_break.append([[i, j], [i + 1, j]])

	var index = randi() % walls_to_break.size()
	var wall_to_break = walls_to_break[index]
	_break_wall(maze, wall_to_break)


func _break_wall(maze, wall_to_break):
	var c1 = wall_to_break[0]
	var c2 = wall_to_break[1]
	var cell1 = maze[c1[0]][c1[1]]
	var cell2 = maze[c2[0]][c2[1]]
	_paint_maze(maze, cell1.area, cell2.area)
	if c1[0] == c2[0]:
		cell1.has_bottom_wall = false
		cell2.has_top_wall = false
	if c1[1] == c2[1]:
		cell1.has_right_wall = false
		cell2.has_left_wall = false


func _paint_maze(maze, area1, area2):
	for column in maze:
		for cell in column:
			if cell.area == area1:
				cell.area = area2


func _distances_from(maze, x, y):
	var result = _generate_cells(maze.size())
	var queue = []
	queue.push_back([x, y, 0])
	result[x][y] = 0
	while !queue.empty():
		var el = queue.pop_front()
		var cx = el[0]
		var cy = el[1]
		var dist = el[2]
		var cell = maze[cx][cy]
		if !cell.has_top_wall and result[cx][cy - 1] == null:
			queue.push_back([cx, cy - 1, dist + 1])
			result[cx][cy - 1] = dist + 1
		if !cell.has_bottom_wall and result[cx][cy + 1] == null:
			queue.push_back([cx, cy + 1, dist + 1])
			result[cx][cy + 1] = dist + 1
		if !cell.has_left_wall and result[cx - 1][cy] == null:
			queue.push_back([cx - 1, cy, dist + 1])
			result[cx - 1][cy] = dist + 1
		if !cell.has_right_wall and result[cx + 1][cy] == null:
			queue.push_back([cx + 1, cy, dist + 1])
			result[cx + 1][cy] = dist + 1
	return result


func _matrix_to_string(matrix, width):
	var result = PoolStringArray()
	var format_string = "%%%ss" % width
	for j in range(matrix.size()):
		var line = PoolStringArray()
		for i in range(matrix.size()):
			var cell = matrix[i][j]
			line.append(format_string % cell)
		result.append(" ".join(line))
	return "\n".join(result)

