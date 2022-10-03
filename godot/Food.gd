extends Area

export (Material) var food_material
export (Material) var poison_material


func initialize(x, y, maze):
	translation = Vector3(x - maze.cells.size() / 2, 0, y - maze.cells.size() / 2)


func _ready():
	set_food()


func collect():
	$MeshInstance.cast_shadow = false
	$AnimationPlayer.play("going_away")
	remove_from_group("food")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "going_away":
		queue_free()

func set_poison():
	$MeshInstance.set_surface_material(0, poison_material)


func set_food():
	$MeshInstance.set_surface_material(0, food_material)