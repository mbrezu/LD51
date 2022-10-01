extends Spatial

var cell_scene = load("res://Cell.tscn")

var CellData = preload("res://CellData.gd")


func _ready():
	var size = 16
	var maze = generate_maze(size)
	for i in range(0, size):
		for j in range(0, size):
			var cell = cell_scene.instance()
			cell.initialize(maze[i][j])
			cell.translate_object_local(Vector3(i - size / 2, 0, j - size / 2))
			add_child(cell)


func generate_maze(size):
	var maze = []
	var counter = 1
	for _i in range(size):
		var column = []
		for _j in range(size):
			var cell = CellData.new(counter)
			counter += 1
			column.append(cell)
		maze.append(column)
	while has_multiple_areas(maze):
		unite_two_random_areas(maze)
	return maze


func has_multiple_areas(maze):
	var areas = []
	for column in maze:
		for cell in column:
			var index = areas.find(cell.area)
			if index == -1:
				areas.append(cell.area)
				if areas.size() > 1:
					return true
	return false


func unite_two_random_areas(maze):
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
	break_wall(maze, wall_to_break)


func break_wall(maze, wall_to_break):
	var c1 = wall_to_break[0]
	var c2 = wall_to_break[1]
	var cell1 = maze[c1[0]][c1[1]]
	var cell2 = maze[c2[0]][c2[1]]
	paint_maze(maze, cell1.area, cell2.area)
	if c1[0] == c2[0]:
		cell1.has_bottom_wall = false
		cell2.has_top_wall = false
	if c1[1] == c2[1]:
		cell1.has_right_wall = false
		cell2.has_left_wall = false


func paint_maze(maze, area1, area2):
	for column in maze:
		for cell in column:
			if cell.area == area1:
				cell.area = area2

