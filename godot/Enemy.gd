extends Area


export (Material) var food_material
export (Material) var poison_material


var x
var y
var maze
var target_position = Vector3.ZERO
var base_speed = 1
var speed_increase = 0
var speed = 1
var player_distances
var activated = false
var hunted = false
var can_go_through_walls = false
var player_x = 0
var player_y = 0
var alive = true


func _ready():
	set_poison()


func initialize(px, py, pmaze):
	x = px
	y = py
	maze = pmaze
	set_enemy_position()
	translation = target_position


func set_normal_speed():
	base_speed = 1
	recalc_speed()


func set_fast_speed():
	base_speed = 2
	recalc_speed()


func set_slow_speed():
	base_speed = 0.5
	recalc_speed()


func recalc_speed():
	speed = base_speed * (1 + speed_increase)


func increase_speed():
	speed_increase += 0.1
	# print_debug("speed increase is ", speed_increase)
	recalc_speed()


func go_through_walls(value):
	can_go_through_walls = value


func set_hunted(value):
	if !alive:
		return
	hunted = value
	if hunted:
		set_food()
	else:
		set_poison()
	animate()


func set_poison():
	$Pivot/MeshInstance.set_surface_material(0, poison_material)


func set_food():
	$Pivot/MeshInstance.set_surface_material(0, food_material)


func animate():
	if !alive:
		return
	if hunted:
		$AnimationPlayer.play("run_away")
	elif activated:
		$AnimationPlayer.play("spin")
	else:
		$AnimationPlayer.stop()


func set_enemy_position():
	target_position = Vector3(x - maze.cells.size() / 2, 0, y - maze.cells.size() / 2)


func new_player_position(distances, px, py):
	var size = maze.cells.size()
	if !activated and (abs(px - x) <= size / 4 and abs(py - y) <= size / 4):
		#print_debug("*** player at: [%s, %s], enemy at [%s, %s] activated!" % [px, py, x, y])
		activated = true
		animate()
	player_distances = distances
	player_x = px
	player_y = py


func kill():
	alive = false
	$Pivot/MeshInstance.cast_shadow = false
	$AnimationPlayer.play("death")


func _negate_all(distances):
	var result = []
	for i in range(distances.size()):
		var column = []
		for j in range(distances.size()):
			column.append(-distances[i][j])
		result.append(column)
	return result


func _process(delta):
	if !activated:
		return

	if translation != target_position:
		var direction = (target_position - translation).normalized()
		var difference = target_position - translation
		var movement = direction * delta * speed
		if movement.length() >= difference.length():
			translation = target_position
		else:
			translation += movement

	if translation == target_position:
		if player_distances == null:
			return
		var distance_here = player_distances[x][y]
		var distances = player_distances
		if hunted:
			distance_here = -distance_here
			distances = _negate_all(player_distances)

		var best_candidate = null
		if can_go_through_walls:
			var dx = 0
			var dy = 0
			if x == player_x:
				dx = 0
				dy = player_y - y
			else:
				dx = player_x - x
				dy = 0
			best_candidate = [dx, dy]
		else:
			var candidates = []
			var size = maze.cells.size()
			if y > 0:
				if (!maze.cells[x][y].has_top_wall or can_go_through_walls) and distances[x][y - 1] < distance_here:
					candidates.append([0, -1])
			if y < size - 1:
				if (!maze.cells[x][y].has_bottom_wall or can_go_through_walls) and distances[x][y + 1] < distance_here:
					candidates.append([0, 1])
			if x > 0:
				if (!maze.cells[x][y].has_left_wall or can_go_through_walls) and distances[x - 1][y] < distance_here:
					candidates.append([-1, 0])
			if x < size - 1:
				if (!maze.cells[x][y].has_right_wall or can_go_through_walls) and distances[x + 1][y] < distance_here:
					candidates.append([1, 0])
			if !candidates.empty():
				best_candidate = candidates[randi() % candidates.size()]

		if best_candidate != null:
			var direction = best_candidate
			x += direction[0]
			y += direction[1]
			x = clamp(x, 0, maze.cells.size() - 1)
			y = clamp(y, 0, maze.cells.size() - 1)
			set_enemy_position()


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == "death":
		queue_free()
