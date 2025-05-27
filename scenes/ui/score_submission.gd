extends Control

@onready var score_label = $Panel/ScoreLabel
@onready var name_input = $Panel/NameInput
@onready var submit_button = $Panel/SubmitButton

var final_score : int = 0

func _ready():
	score_label.text = "Your Score: %d" % final_score
	submit_button.pressed.connect(_on_submit_pressed)
	submit_button.grab_focus()

func set_score(score : int):
	final_score = score
	score_label.text = "Your Score: %d" % final_score

func _on_submit_pressed():
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = "Anonymous"
	
	SilentWolf.Scores.persist_score(player_name, final_score, "voll_man_leaderboard")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
