extends Node3D

@onready var world_manager = $WorldManager
@onready var hud = $Hud
@onready var player = $Player

func _ready():
	if not world_manager:
		print("Error: WorldManager no encontrado!")
		return
	
	if not hud:
		print("Error: Hud no encontrado!")
	else:
		world_manager.hud = hud
		world_manager.score_updated.connect(hud.update_score)
	
	if not player:
		print("Error: Player no encontrado!")
	else:
		player.add_to_group("player")
		if player.has_signal("player_died"):
			player.player_died.connect(world_manager._on_player_died)
	
	world_manager.game_started.connect(_on_game_started)
	world_manager.game_ended.connect(_on_game_ended)

	# Iniciar el juego directamente al entrar en la escena
	world_manager.start_game()

func _on_game_started():
	if player and player.has_method("reset"):
		player.reset()
		if player.has_method("enable_movement"):
			player.enable_movement()

func _on_game_ended():
	if hud:
		hud.visible = false
	
	var score_submission = preload("res://scenes/ui/score_submission.tscn").instantiate()
	if score_submission.has_method("set_score") and world_manager:
		score_submission.set_score(world_manager.score)
	add_child(score_submission)

func hide_hud():
	var hud = $HUD  # Asegúrate de que esta sea la ruta correcta
	if hud:
		hud.visible = false
