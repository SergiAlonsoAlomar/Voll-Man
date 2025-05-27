extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel
@onready var speed_label = $SpeedLabel

func _ready():
	# Verificar que todos los labels existen
	if not score_label:
		print("Error: ScoreLabel no encontrado!")
	if not high_score_label:
		print("Error: HighScoreLabel no encontrado!")
	if not speed_label:
		print("Error: SpeedLabel no encontrado!")

func update_score(new_score : int):
	if score_label:
		score_label.text = "Score: %d" % new_score

func update_high_score(score : int):
	if high_score_label:
		high_score_label.text = "High Score: %d" % score

func update_speed(current_speed : float):
	if speed_label:
		speed_label.text = "Speed: %.1f" % current_speed
