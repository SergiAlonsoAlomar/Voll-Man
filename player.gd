extends CharacterBody3D

# Constantes configurables
const SPEED = 5.0
const FORWARD_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.8  # En metros por segundo al cuadrado

# Nodo de la cámara
@export var camera : Camera3D

# Offset (distancia) entre el jugador y la cámara
const CAMERA_OFFSET = Vector3(0, 3, -5)

func _ready():
	# Establece la cámara para que siga al jugador
	camera = $Camera3D

func _physics_process(delta):
	# Añade la gravedad manualmente
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Maneja el salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtiene la dirección del movimiento desde teclado y mando
	var input_dir = get_input_direction()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Movimiento horizontal
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	# Movimiento hacia adelante automático
	velocity.z = FORWARD_SPEED

	# Aplica el movimiento
	move_and_slide()
	
	# Actualiza la posición de la cámara para que siga al jugador
	follow_camera()
	
# Función para obtener entradas tanto del teclado como del mando
func get_input_direction() -> Vector2:
	var input_dir = Vector2.ZERO

	# Entradas del teclado
	input_dir.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")

	return input_dir

# Función para hacer que la cámara siga al jugador
func follow_camera():
	# Mantén la misma posición en los ejes x y y de la cámara, pero actualiza solo el eje z
	var target_position = global_transform.origin
	target_position.z = global_transform.origin.z + CAMERA_OFFSET.z  # Solo modifica el eje Z
