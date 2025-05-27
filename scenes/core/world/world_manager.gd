extends Node
class_name WorldManager

# Señales correctamente implementadas
signal score_updated(new_score)  # Se emite al actualizar puntuación
signal game_started              # Se emite al iniciar el juego
signal game_ended                # Se emite al terminar el juego

@export var chunk_scenes : Array[PackedScene] = []
@export var chunk_spacing : float = 30.0
@export var base_speed : float = 5.0
@export var max_speed : float = 20.0
@export var speed_increase_rate : float = 0.02
@export var initial_chunks : int = 3

var current_speed : float
var active_chunks : Array = []
var score : int = 0
var high_score : int = 0
var is_game_running : bool = false
var player : CharacterBody3D = null
var hud : CanvasLayer = null

func _ready():
	current_speed = base_speed
	load_high_score()
	if hud:
		hud.update_high_score(high_score)

func _process(delta):
	if not is_game_running or player == null:
		return
	
	current_speed = min(current_speed + speed_increase_rate * delta, max_speed)
	
	for chunk in active_chunks:
		if is_instance_valid(chunk):
			chunk.move_speed = current_speed
	
	score += int(current_speed * delta * 2.0)
	emit_signal("score_updated", score)
	if hud:
		hud.update_score(score)

func start_game():
	if is_game_running:
		return
	
	score = 0
	current_speed = base_speed
	is_game_running = true
	emit_signal("game_started")
	emit_signal("score_updated", score)
	
	player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)
	
	setup_chunks()

func stop_game():
	if not is_game_running:
		return
	
	is_game_running = false
	emit_signal("game_ended")
	
	if score > high_score:
		high_score = score
		save_high_score()
		if hud:
			hud.update_high_score(high_score)
	
	for chunk in active_chunks:
		if is_instance_valid(chunk):
			chunk.queue_free()
	active_chunks.clear()

func setup_chunks():
	for chunk in active_chunks:
		if is_instance_valid(chunk):
			chunk.queue_free()
	active_chunks.clear()
	
	for i in range(initial_chunks):
		spawn_chunk(i * chunk_spacing)

func spawn_chunk(z_position : float):
	if chunk_scenes.is_empty():
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var chunk_index = rng.randi_range(0, chunk_scenes.size() - 1)
	var new_chunk = chunk_scenes[chunk_index].instantiate()
	
	new_chunk.position.z = z_position
	new_chunk.move_speed = current_speed
	if new_chunk.has_signal("chunk_exited"):
		new_chunk.chunk_exited.connect(_on_chunk_exited)
	
	add_child(new_chunk)
	active_chunks.append(new_chunk)

func _on_chunk_exited():
	if active_chunks.size() > 0:
		var exited_chunk = active_chunks.pop_front()
		if is_instance_valid(exited_chunk):
			exited_chunk.queue_free()
	
	if active_chunks.size() > 0:
		var last_chunk = active_chunks.back()
		if is_instance_valid(last_chunk):
			spawn_chunk(last_chunk.position.z - chunk_spacing)

func _on_player_died():
	stop_game()

func add_score(points : int):
	score += points
	emit_signal("score_updated", score)
	if hud:
		hud.update_score(points)

func load_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var save_file = FileAccess.open("user://highscore.save", FileAccess.READ)
		if save_file:
			high_score = save_file.get_32()
			save_file.close()

func save_high_score():
	var save_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	if save_file:
		save_file.store_32(high_score)
		save_file.close()
