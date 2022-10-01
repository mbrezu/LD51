extends Spatial


func initialize(cell_data):
	$FrontWall.visible = cell_data.has_bottom_wall
	$BackWall.visible = cell_data.has_top_wall
	$LeftWall.visible = cell_data.has_left_wall
	$RightWall.visible = cell_data.has_right_wall