extends Spatial

var cell_scene = load("res://Cell.tscn")
var player_scene = load("res://Player.tscn")

var Maze = preload("res://Maze.gd")


func _ready():
	randomize()
	var size = 16
	var maze = Maze.new(size)
	for i in range(0, size):
		for j in range(0, size):
			var cell = cell_scene.instance()
			cell.initialize(maze.cells[i][j])
			cell.translate_object_local(Vector3(i - size / 2, 0, j - size / 2))
			add_child(cell)
	var player = player_scene.instance()
	player.initialize(maze)
	add_child(player)
