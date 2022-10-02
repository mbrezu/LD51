extends CanvasLayer

signal counter_elapsed

var counter = 10
var score = 0


func _ready():
	$UI/CounterLabel.text = str(counter)


func new_game():
	$CounterTimer.start()
	show_score()


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