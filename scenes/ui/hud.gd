extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel
@onready var speed_label = $SpeedLabel
@onready var pause_button = $PauseButton

var pause_menu_instance: Control = null
var pause_menu_scene := preload("res://scenes/ui/PauseMenu.tscn")

func _ready():
	if not score_label:
		print("Error: ScoreLabel no encontrado!")
	if not high_score_label:
		print("Error: HighScoreLabel no encontrado!")
	if not speed_label:
		print("Error: SpeedLabel no encontrado!")
	if not pause_button:
		print("Error: PauseButton no encontrado!")

	if pause_button:
		pause_button.pressed.connect(_on_pause_button_pressed)

func update_score(new_score: int):
	if score_label:
		score_label.text = "Score: %d" % new_score

func update_high_score(score: int):
	if high_score_label:
		high_score_label.text = "High Score: %d" % score

func update_speed(current_speed: float):
	if speed_label:
		speed_label.text = "Speed: %.1f" % current_speed

func _on_pause_button_pressed():
	if get_tree().paused:
		get_tree().paused = false
	else:
		_pause_game()

func _pause_game():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if pause_menu_instance == null:
		pause_menu_instance = pause_menu_scene.instantiate()
		add_child(pause_menu_instance)

	pause_menu_instance.visible = true
