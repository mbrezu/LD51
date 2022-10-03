extends Node

var first_time = true

enum Modifications {
	NONE
	ZOOM_IN,
	FASTER_PLAYER,
	SLOWER_PLAYER,
	FASTER_ENEMIES,
	SLOWER_ENEMIES,
	PLAYER_GOES_THROUGH_WALLS,
	SPAWN_ENEMIES,
	DOUBLE_WORTH_FOOD,
	FOOD_IS_POISON,
	HUNT_ENEMIES,
	ENEMIES_GO_THROUGH_WALLS,
	RESPAWN_FOOD, # triggered when no food left, don't add to deck.
	KILL_SOME_GUARDS # triggered when there are too many guards, don't add to deck.
}

var _modifications_deck = [
	Modifications.NONE,
	Modifications.NONE,
	Modifications.NONE,
	Modifications.NONE,
	Modifications.NONE,
	Modifications.NONE,
	Modifications.ZOOM_IN,
	Modifications.ZOOM_IN,
	Modifications.ZOOM_IN,
	Modifications.FASTER_PLAYER,
	Modifications.SLOWER_PLAYER,
	Modifications.FASTER_ENEMIES,
	Modifications.SLOWER_ENEMIES,
	Modifications.SLOWER_ENEMIES,
	Modifications.SLOWER_ENEMIES,
	Modifications.PLAYER_GOES_THROUGH_WALLS,
	Modifications.PLAYER_GOES_THROUGH_WALLS,
	Modifications.PLAYER_GOES_THROUGH_WALLS,
	Modifications.SPAWN_ENEMIES,
	Modifications.SPAWN_ENEMIES,
	Modifications.SPAWN_ENEMIES,
	Modifications.SPAWN_ENEMIES,
	Modifications.DOUBLE_WORTH_FOOD,
	Modifications.DOUBLE_WORTH_FOOD,
	Modifications.DOUBLE_WORTH_FOOD,
	Modifications.DOUBLE_WORTH_FOOD,
	Modifications.FOOD_IS_POISON,
	Modifications.FOOD_IS_POISON,
	Modifications.HUNT_ENEMIES,
	Modifications.HUNT_ENEMIES,
	Modifications.HUNT_ENEMIES,
	Modifications.ENEMIES_GO_THROUGH_WALLS,
	Modifications.ENEMIES_GO_THROUGH_WALLS
]

var _modifications_left = []


func get_modification():
	if _modifications_left.empty():
		for mod in _modifications_deck:
			_modifications_left.push_back(mod)
		_modifications_left.shuffle()
	return _modifications_left.pop_back()
