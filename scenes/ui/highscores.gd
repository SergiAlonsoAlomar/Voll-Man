extends Control

@onready var scores_container = $Panel/CenterContainer/VBoxContainer
@onready var back_button = $Panel/CenterContainer/VBoxContainer/BackButton

func _ready():
	await get_tree().process_frame

	if back_button:
		back_button.grab_focus()
		back_button.pressed.connect(_on_back_button_pressed)
	
	load_high_scores()

func _on_back_button_pressed():
	await get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func load_high_scores():
	# Limpiar contenedor de puntuacions
	for child in scores_container.get_children():
		if child != back_button:
			child.queue_free()
	
	# Mostrar mensaje de carga
	var loading_label = Label.new()
	loading_label.text = "Loading scores..."
	scores_container.add_child(loading_label)

	# Solicitar puntuaciones asincrónicamente
	await get_and_display_scores()

func get_and_display_scores():
	# Obtener las 10 mejores puntuaciones
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(10).sw_get_scores_complete
	print("Scores: " + str(sw_result.scores))

	# Limpiar mensaje de carga
	for child in scores_container.get_children():
		if child != back_button:
			child.queue_free()
	
	var scores = sw_result.scores

	if scores.is_empty():
		var no_scores_label = Label.new()
		no_scores_label.text = "No scores yet!"
		scores_container.add_child(no_scores_label)
	else:
		for i in range(scores.size()):
			var score_data = scores[i]
			var score_label = Label.new()
			score_label.text = "%d. %s - %d" % [i + 1, score_data.player_name, score_data.score]
			scores_container.add_child(score_label)
