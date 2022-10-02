extends CanvasLayer

signal counter_elapsed
signal new_game

var counter = 10
var score = 0


func _ready():
	$UI/CounterLabel.text = str(counter)
	$Button.visible = true
	$GameOverLabel.visible = false


func new_game():
	$CounterTimer.start()
	$UI.visible = true
	show_score()
	$Button.visible = false


func show_score():
	$UI/ScoreLabel.text = "Score: %s" % score


func _on_CounterTimer_timeout():
	counter -= 1
	if counter == 0:
		counter = 10
		emit_signal("counter_elapsed")
	$UI/CounterLabel.text = str(counter)


func increment_score(value):
	score += value
	show_score()


func game_over():
	$CounterTimer.stop()
	$GameOverTimer.start()
	$GameOverLabel.visible = true


func show_modification(modification):
	match modification:
		Global.Modifications.NONE:
			$UI/ModificationLabel.text = "No modifications."
		Global.Modifications.ZOOM_IN:
			$UI/ModificationLabel.text = "Camera zoomed in."
		Global.Modifications.FASTER_PLAYER:
			$UI/ModificationLabel.text = "Player moves faster."
		Global.Modifications.SLOWER_PLAYER:
			$UI/ModificationLabel.text = "Player moves slower."
		Global.Modifications.FASTER_ENEMIES:
			$UI/ModificationLabel.text = "Enemies move faster."
		Global.Modifications.SLOWER_ENEMIES:
			$UI/ModificationLabel.text = "Enemies move slower."
		Global.Modifications.GO_THROUGH_WALLS:
			$UI/ModificationLabel.text = "Player can go through walls."
		Global.Modifications.RESPAWN_FOOD:
			$UI/ModificationLabel.text = "Coins respawned."
		Global.Modifications.SPAWN_ENEMIES:
			$UI/ModificationLabel.text = "More guards spawned."


func _on_GameOverTimer_timeout():
	$Button.visible = true


func _on_Button_pressed():
	emit_signal("new_game")
