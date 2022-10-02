extends Spatial


func initialize(cell_data):
	$Pivot/FrontWall.visible = cell_data.has_bottom_wall
	$Pivot/BackWall.visible = cell_data.has_top_wall
	$Pivot/LeftWall.visible = cell_data.has_left_wall
	$Pivot/RightWall.visible = cell_data.has_right_wall


func sink():
	$AnimationPlayer.queue("sink")


func restore():
	$AnimationPlayer.queue("restore")