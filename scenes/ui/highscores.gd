extends Control

@onready var scores_container = $VBoxContainer
@onready var back_button = $BackButton

func _ready():
	back_button.grab_focus()
	back_button.pressed.connect(_on_back_button_pressed)
	load_high_scores()

func load_high_scores():
	# Limpiar contenedor
	for child in scores_container.get_children():
		child.queue_free()
	
	# Mostrar mensaje de carga
	var loading_label = Label.new()
	loading_label.text = "Loading scores..."
	scores_container.add_child(loading_label)
	
	# Solicitar puntuaciones
	SilentWolf.Scores.get_scores(10).sw_get_scores_complete.connect(_on_scores_loaded)

func _on_scores_loaded():
	# Limpiar mensaje de carga
	for child in scores_container.get_children():
		child.queue_free()
	
	# Mostrar puntuaciones
	var scores = SilentWolf.Scores.scores
	if scores.is_empty():
		var no_scores_label = Label.new()
		no_scores_label.text = "No scores yet!"
		scores_container.add_child(no_scores_label)
	else:
		for i in range(scores.size()):
			var score_data = scores[i]
			var score_label = Label.new()
			score_label.text = "%d. %s - %d" % [i+1, score_data.player_name, score_data.score]
			scores_container.add_child(score_label)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
