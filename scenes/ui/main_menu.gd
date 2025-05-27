extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var scores_button = $CenterContainer/VBoxContainer/ScoresButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready():
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_button_pressed)
	scores_button.pressed.connect(_on_scores_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_scores_button_pressed():
	# Cambiar a escena de puntuaciones (implementar después)
	get_tree().change_scene_to_file("res://scenes/ui/highscores.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
