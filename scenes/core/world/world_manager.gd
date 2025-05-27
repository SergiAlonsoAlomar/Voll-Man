extends Node3D
class_name WorldManager

# Señales
signal score_updated(new_score)
signal game_started
signal game_ended

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
	print("WorldManager ready - Chunks disponibles: ", chunk_scenes.size())

func _process(delta):
	if not is_game_running:
		return
	
	# Actualizar velocidad
	current_speed = min(current_speed + speed_increase_rate * delta, max_speed)
	
	# Actualizar velocidad de chunks
	for chunk in active_chunks:
		if is_instance_valid(chunk) and chunk.has_method("set_move_speed"):
			chunk.move_speed = current_speed
	
	# Actualizar puntuación
	score += int(current_speed * delta * 2.0)
	emit_signal("score_updated", score)
	
	# Actualizar HUD si existe
	if hud and hud.has_method("update_speed"):
		hud.update_speed(current_speed)

func start_game():
	print("Iniciando juego...")
	if is_game_running:
		return
	
	score = 0
	current_speed = base_speed
	is_game_running = true
	
	# Buscar el jugador
	player = get_tree().get_first_node_in_group("player")
	if not player:
		# Si no está en el grupo, buscar por nombre
		player = get_node_or_null("../Player")
	
	if player:
		print("Jugador encontrado: ", player.name)
		if player.has_signal("player_died"):
			if not player.player_died.is_connected(_on_player_died):
				player.player_died.connect(_on_player_died)
	else:
		print("¡ADVERTENCIA! No se encontró el jugador")
	
	# Configurar chunks
	setup_chunks()
	
	# Emitir señal
	emit_signal("game_started")
	emit_signal("score_updated", score)

func setup_chunks():
	print("Configurando chunks...")
	
	# Limpiar chunks existentes
	for chunk in active_chunks:
		if is_instance_valid(chunk):
			chunk.queue_free()
	active_chunks.clear()
	
	# Verificar que tenemos escenas de chunks
	if chunk_scenes.is_empty():
		print("¡ERROR! No hay chunk_scenes configuradas")
		create_default_chunk()
		return
	
	# Crear chunks iniciales
	for i in range(initial_chunks):
		spawn_chunk(-i * chunk_spacing)  # Posición negativa en Z para que aparezcan delante

func create_default_chunk():
	"""Crear un chunk básico si no hay escenas configuradas"""
	print("Creando chunk por defecto...")
	
	var chunk = Node3D.new()
	chunk.name = "DefaultChunk"
	
	# Crear plataforma básica
	var platform = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(10.0, 0.5, 30.0)
	platform.mesh = box_mesh
	
	# Material para la plataforma
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.5)
	platform.set_surface_override_material(0, material)
	
	# Añadir colisión
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = box_mesh.size
	collision_shape.shape = box_shape
	
	static_body.add_child(collision_shape)
	platform.add_child(static_body)
	chunk.add_child(platform)
	
	# Posicionar el chunk
	chunk.position = Vector3(0, -1, 0)
	add_child(chunk)
	active_chunks.append(chunk)

func spawn_chunk(z_position: float):
	if chunk_scenes.is_empty():
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var chunk_index = rng.randi_range(0, chunk_scenes.size() - 1)
	var new_chunk = chunk_scenes[chunk_index].instantiate()
	
	if not new_chunk:
		print("Error al instanciar chunk")
		return
	
	new_chunk.position.z = z_position
	new_chunk.move_speed = current_speed
	
	# Conectar señal si existe
	if new_chunk.has_signal("chunk_exited"):
		new_chunk.chunk_exited.connect(_on_chunk_exited)
	
	add_child(new_chunk)
	active_chunks.append(new_chunk)
	print("Chunk spawneado en posición Z: ", z_position)

func _on_chunk_exited():
	if active_chunks.size() > 0:
		var exited_chunk = active_chunks.pop_front()
		if is_instance_valid(exited_chunk):
			exited_chunk.queue_free()
	
	# Spawn nuevo chunk
	if active_chunks.size() > 0:
		var last_chunk = active_chunks.back()
		if is_instance_valid(last_chunk):
			spawn_chunk(last_chunk.position.z - chunk_spacing)

func _on_player_died():
	stop_game()

func stop_game():
	if not is_game_running:
		return
	
	is_game_running = false
	emit_signal("game_ended")
	
	if score > high_score:
		high_score = score
		save_high_score()

func add_score(points: int):
	score += points
	emit_signal("score_updated", score)

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
