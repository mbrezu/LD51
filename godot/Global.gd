extends Node

var first_time = true

enum Modifications {
    NONE
    ZOOM_IN,
    FASTER_PLAYER,
    SLOWER_PLAYER,
    FASTER_ENEMIES,
    SLOWER_ENEMIES,
    GO_THROUGH_WALLS,
    RESPAWN_FOOD,
    SPAWN_ENEMIES,
    DOUBLE_WORTH_FOOD
}

var _modifications_deck = [
    Modifications.NONE,
    Modifications.NONE,
    Modifications.NONE,
    Modifications.NONE,
    Modifications.ZOOM_IN,
    Modifications.ZOOM_IN,
    Modifications.FASTER_PLAYER,
    Modifications.SLOWER_PLAYER,
    Modifications.FASTER_ENEMIES,
    Modifications.SLOWER_ENEMIES,
    Modifications.GO_THROUGH_WALLS,
    Modifications.RESPAWN_FOOD,
    Modifications.SPAWN_ENEMIES,
    Modifications.DOUBLE_WORTH_FOOD,
    Modifications.DOUBLE_WORTH_FOOD,
]

var _modifications_left = []


func get_modification():
    if _modifications_left.empty():
        for mod in _modifications_deck:
            _modifications_left.push_back(mod)
        _modifications_left.shuffle()
    return _modifications_left.pop_back()