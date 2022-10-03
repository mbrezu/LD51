extends Spatial

export (Material) var solid_wall
export (Material) var broken_wall


func _ready():
	set_solid_wall()


func set_solid_wall():
	$Pivot/FrontWall.set_surface_material(0, solid_wall)
	$Pivot/BackWall.set_surface_material(0, solid_wall)
	$Pivot/LeftWall.set_surface_material(0, solid_wall)
	$Pivot/RightWall.set_surface_material(0, solid_wall)


func set_broken_wall():
	$Pivot/FrontWall.set_surface_material(0, broken_wall)
	$Pivot/BackWall.set_surface_material(0, broken_wall)
	$Pivot/LeftWall.set_surface_material(0, broken_wall)
	$Pivot/RightWall.set_surface_material(0, broken_wall)


func initialize(cell_data):
	$Pivot/FrontWall.visible = cell_data.has_bottom_wall
	$Pivot/BackWall.visible = cell_data.has_top_wall
	$Pivot/LeftWall.visible = cell_data.has_left_wall
	$Pivot/RightWall.visible = cell_data.has_right_wall


func sink():
	$AnimationPlayer.queue("sink")


func restore():
	$AnimationPlayer.queue("restore")
