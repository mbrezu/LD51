extends Spatial

var cell_scene = load("res://Cell.tscn")
var player_scene = load("res://Player.tscn")
var enemy_scene = load("res://Enemy.tscn")
var food_scene = load("res://Food.tscn")

var Maze = preload("res://Maze.gd")

var modification = Global.Modifications.NONE
var player
var maze
var food_multiplier = 1

var sound_jingles = []
var sound_food = []

var center_food = false


func _ready():
	randomize()
	sound_jingles = [
		$Sound/Jingle1,
		$Sound/Jingle2,
		$Sound/Jingle3,
		$Sound/Jingle4
	]
	sound_food = [
		$Sound/Food1,
		$Sound/Food2
	]
	if !Global.first_time:
		new_game()


func new_game():
	play_jingle()

	var size = 15
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

	spawn_enemies()

	spawn_food()

	$HUD.new_game()


func play_jingle():
	if !sound_jingles.empty():
		sound_jingles.shuffle()
		sound_jingles[0].play()


func play_food():
	if !sound_food.empty():
		sound_food.shuffle()
		sound_food[0].play()


func spawn_enemies():
	var size = maze.cells.size()
	add_enemy(0, 0)
	add_enemy(0, size - 1)
	add_enemy(size - 1, 0)
	add_enemy(size - 1, size - 1)


func spawn_food():
	var size = maze.cells.size()
	var mid = size / 2
	var food_square_size = int(size / 5)

	if center_food:
		for i in range(mid - food_square_size, mid + food_square_size):
			for j in range(mid - food_square_size, mid + food_square_size):
				add_food(i, j)
	else:
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

	center_food = !center_food


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
	var food_array = get_tree().get_nodes_in_group("food")
	var enemy_array = get_tree().get_nodes_in_group("enemy")
	if food_array.empty():
		modification = Global.Modifications.RESPAWN_FOOD
	elif enemy_array.size() > 8:
		if randf() < 0.5:
			modification = Global.Modifications.KILL_SOME_GUARDS
		else:
			modification = Global.Modifications.HUNT_ENEMIES
	elif enemy_array.empty():
		modification = Global.Modifications.SPAWN_ENEMIES
	else:
		modification = Global.get_modification()
	if modification == Global.Modifications.FOOD_IS_POISON:
		if min_player_food_distance() < 3:
			var to_put_back = []
			while modification == Global.Modifications.FOOD_IS_POISON:
				to_put_back.push_back(modification)
				modification = Global.get_modification()
			for mod in to_put_back:
				Global.put_back_modification(mod)
	player.shake()
	play_jingle()
	apply_current_modification()


func min_player_food_distance():
	var min_distance = 1000
	for food in get_tree().get_nodes_in_group("food"):
		var distance = (player.translation - food.translation).length()
		# print_debug(distance)
		if distance < min_distance:
			min_distance = distance
	return min_distance


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
		Global.Modifications.PLAYER_GOES_THROUGH_WALLS:
			get_tree().call_group("cell", "restore")
			player.can_go_through_walls = false
		Global.Modifications.ENEMIES_GO_THROUGH_WALLS:
			get_tree().call_group("enemy", "go_through_walls", false)
			get_tree().call_group("cell", "set_solid_wall")
		Global.Modifications.RESPAWN_FOOD:
			pass
		Global.Modifications.SPAWN_ENEMIES:
			pass
		Global.Modifications.DOUBLE_WORTH_FOOD:
			food_multiplier = 1
		Global.Modifications.KILL_SOME_GUARDS:
			pass
		Global.Modifications.FOOD_IS_POISON:
			player.food_is_poison = false
			get_tree().call_group("food", "set_food")
		Global.Modifications.HUNT_ENEMIES:
			player.hunt_enemies = false
			get_tree().call_group("enemy", "set_hunted", false)


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
		Global.Modifications.PLAYER_GOES_THROUGH_WALLS:
			get_tree().call_group("cell", "sink")
			player.can_go_through_walls = true
		Global.Modifications.ENEMIES_GO_THROUGH_WALLS:
			get_tree().call_group("enemy", "go_through_walls", true)
			get_tree().call_group("cell", "set_broken_wall")
		Global.Modifications.ZOOM_IN:
			if player != null:
				player.zoom_in()
		Global.Modifications.RESPAWN_FOOD:
			get_tree().call_group("food", "collect")
			get_tree().call_group("enemy", "increase_speed")
			spawn_food()
		Global.Modifications.SPAWN_ENEMIES:
			spawn_enemies()
		Global.Modifications.DOUBLE_WORTH_FOOD:
			food_multiplier = 2
		Global.Modifications.KILL_SOME_GUARDS:
			var guards = get_tree().get_nodes_in_group("enemy")
			guards.shuffle()
			var guards_to_kill = guards.slice(0, int(guards.size() / 3))
			for guard in guards_to_kill:
				guard.kill()
		Global.Modifications.FOOD_IS_POISON:
			player.food_is_poison = true
			get_tree().call_group("food", "set_poison")
		Global.Modifications.HUNT_ENEMIES:
			player.hunt_enemies = true
			get_tree().call_group("enemy", "set_hunted", true)


func _on_player_food_collected():
	$HUD.increment_score(food_multiplier)
	play_food()


func _on_player_died():
	$HUD.game_over()
	$Sound/PlayerDeath.play()


func _on_HUD_new_game():
	if Global.first_time:
		new_game()
		Global.first_time = false
	else:
		var _x = get_tree().reload_current_scene()
