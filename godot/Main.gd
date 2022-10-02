extends Spatial

var cell_scene = load("res://Cell.tscn")
var player_scene = load("res://Player.tscn")
var enemy_scene = load("res://Enemy.tscn")
var food_scene = load("res://Food.tscn")

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
	player.connect("new_position", self, "_on_player_new_position")
	add_child(player)

	add_enemy(1, 1, maze)
	add_enemy(1, size - 2, maze)
	add_enemy(size - 2, 1, maze)
	add_enemy(size - 2, size - 2, maze)

	for _i in range(size):
		var x = randi() % size
		var y = randi() % size
		add_food(x, y, maze)


func add_enemy(x, y, maze):
	var enemy = enemy_scene.instance()
	enemy.initialize(x, y, maze)
	add_child(enemy)


func add_food(x, y, maze):
	var food = food_scene.instance()
	food.initialize(x, y, maze)
	add_child(food)


func _on_player_new_position(distances):
	get_tree().call_group("enemy", "new_player_position", distances)