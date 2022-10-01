extends Spatial


var x
var y
var maze
var target_position = Vector3.ZERO
var speed = 2


func initialize(px, py, pmaze):
	x = px
	y = py
	maze = pmaze
	set_food_position()
	translation = target_position


func set_food_position():
	target_position = Vector3(x - maze.cells.size() / 2, 0, y - maze.cells.size() / 2)