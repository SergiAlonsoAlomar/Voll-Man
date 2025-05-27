extends Node3D

# Referencias a los nodos principales
@onready var world_manager = $WorldManager
@onready var hud = $Hud
@onready var player = $Player
@onready var camera = $Camera3D

func _ready():
	# Verificar que los nodos existen
	if not world_manager:
		print("Error: WorldManager no encontrado!")
		return
	
	if not hud:
		print("Error: Hud no encontrado!")
		return
	
	if not player:
		print("Error: Player no encontrado!")
		return
	
	# Configurar las conexiones
	setup_connections()
	
	# Configurar la cámara para seguir al jugador
	setup_camera()
	
	# Iniciar el juego automáticamente
	start_game()

func setup_connections():
	# Conectar señales del world_manager
	if world_manager.has_signal("score_updated"):
		world_manager.score_updated.connect(hud.update_score)
	
	if world_manager.has_signal("game_started"):
		world_manager.game_started.connect(_on_game_started)
	
	if world_manager.has_signal("game_ended"):
		world_manager.game_ended.connect(_on_game_ended)
	
	# Conectar señales del player si existen
	if player.has_signal("player_died"):
		player.player_died.connect(world_manager._on_player_died)

func setup_camera():
	if camera and player:
		# Posicionar la cámara detrás del jugador
		camera.position = Vector3(0, 5, 10)
		camera.look_at(player.position, Vector3.UP)

func start_game():
	if world_manager:
		world_manager.start_game()

func _on_game_started():
	print("Juego iniciado!")
	if player and player.has_method("reset"):
		player.reset()
	if player and player.has_method("enable_movement"):
		player.enable_movement()

func _on_game_ended():
	print("Juego terminado!")
	# Aquí puedes agregar lógica para mostrar pantalla de game over
