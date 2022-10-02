extends Node

var first_time = true

enum Modifications {
    NONE
    ZOOM_IN,
    FASTER_PLAYER,
    SLOWER_PLAYER,
    FASTER_ENEMIES
}

var _modifications_deck = [
    Modifications.FASTER_ENEMIES,
]

var _modifications_left = []


func get_modification():
    if _modifications_left.empty():
        for mod in _modifications_deck:
            _modifications_left.push_back(mod)
        _modifications_left.shuffle()
    return _modifications_left.pop_back()