extends Spatial

var cell_scene = load("res://Cell.tscn")
var player_scene = load("res://Player.tscn")
var enemy_scene = load("res://Enemy.tscn")
var food_scene = load("res://Food.tscn")

var Maze = preload("res://Maze.gd")

var modification = Global.Modifications.NONE
var player
var maze


func _ready():
	randomize()
	if !Global.first_time:
		new_game()


func new_game():
	var size = 20
	maze = Maze.new(size)
	for i in range(0, size):
		for j in range(0, size):
			var cell = cell_scene.instance()
			cell.initialize(maze.cells[i][j])
			cell.translate_object_local(Vector3(i - size / 2, 0, j - size / 2))
			add_child(cell)
	player = player_scene.instance()
	player.initialize(maze)
	player.connect("new_position", self, "_on_player_new_position")
	player.connect("food_collected", self, "_on_player_food_collected")
	player.connect("died", self, "_on_player_died")
	add_child(player)

	add_enemy(0, 0)
	add_enemy(0, size - 1)
	add_enemy(size - 1, 0)
	add_enemy(size - 1, size - 1)

	spawn_food()

	$HUD.new_game()


func spawn_food():
	var size = maze.cells.size()
	var food_square_size = int(size / 5)

	for i in range(food_square_size):
		for j in range(food_square_size):
			add_food(i, j)

	for i in range(size - food_square_size, size):
		for j in range(food_square_size):
			add_food(i, j)

	for i in range(food_square_size):
		for j in range(size - food_square_size, size):
			add_food(i, j)

	for i in range(size - food_square_size, size):
		for j in range(size - food_square_size, size):
			add_food(i, j)


func add_enemy(x, y):
	var enemy = enemy_scene.instance()
	enemy.initialize(x, y, maze)
	add_child(enemy)


func add_food(x, y):
	var food = food_scene.instance()
	food.initialize(x, y, maze)
	add_child(food)


func _on_player_new_position(distances, px, py):
	get_tree().call_group("enemy", "new_player_position", distances, px, py)


func _on_HUD_counter_elapsed():
	unapply_current_modification()
	modification = Global.get_modification()
	apply_current_modification()


func unapply_current_modification():
	match modification:
		Global.Modifications.NONE:
			pass
		Global.Modifications.ZOOM_IN:
			if player != null:
				player.zoom_out()
		Global.Modifications.FASTER_PLAYER:
			player.set_normal_speed()
		Global.Modifications.SLOWER_PLAYER:
			player.set_normal_speed()
		Global.Modifications.FASTER_ENEMIES:
			get_tree().call_group("enemy", "set_normal_speed")
		Global.Modifications.SLOWER_ENEMIES:
			get_tree().call_group("enemy", "set_normal_speed")
		Global.Modifications.GO_THROUGH_WALLS:
			get_tree().call_group("cell", "restore")
			player.can_go_through_walls = false
		Global.Modifications.RESPAWN_FOOD:
			pass


func apply_current_modification():
	$HUD.show_modification(modification)
	match modification:
		Global.Modifications.NONE:
			pass
		Global.Modifications.FASTER_PLAYER:
			player.set_fast_speed()
		Global.Modifications.SLOWER_PLAYER:
			player.set_slow_speed()
		Global.Modifications.FASTER_ENEMIES:
			get_tree().call_group("enemy", "set_fast_speed")
		Global.Modifications.SLOWER_ENEMIES:
			get_tree().call_group("enemy", "set_slow_speed")
		Global.Modifications.GO_THROUGH_WALLS:
			get_tree().call_group("cell", "sink")
			player.can_go_through_walls = true
		Global.Modifications.ZOOM_IN:
			if player != null:
				player.zoom_in()
		Global.Modifications.RESPAWN_FOOD:
			get_tree().call_group("food", "collect")
			spawn_food()



func _on_player_food_collected():
	$HUD.increment_score(1)


func _on_player_died():
	$HUD.game_over()


func _on_HUD_new_game():
	if Global.first_time:
		new_game()
		Global.first_time = false
	else:
		var _x = get_tree().reload_current_scene()
