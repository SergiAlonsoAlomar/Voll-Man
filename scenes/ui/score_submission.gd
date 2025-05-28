extends Control

@onready var score_label = $Panel/CenterContainer/VBoxContainer/ScoreLabel
@onready var name_input = $Panel/CenterContainer/VBoxContainer/NameInput
@onready var submit_button = $Panel/CenterContainer/VBoxContainer/SubmitButton

var final_score : int = 0

func _ready():
	# Mostrar la puntuación final si ya estaba asignada
	if score_label:
		score_label.text = "Your Score: %d" % final_score
	
	submit_button.pressed.connect(_on_submit_pressed)
	submit_button.grab_focus()

func set_score(score : int):
	final_score = score
	# Solo asignar si el nodo ya está listo
	if is_inside_tree() and score_label:
		score_label.text = "Your Score: %d" % final_score

func _on_submit_pressed():
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = "Anonymous"
	
	SilentWolf.Scores.save_score(player_name, final_score)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
