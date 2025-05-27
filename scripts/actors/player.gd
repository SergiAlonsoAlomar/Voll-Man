extends CharacterBody3D

# Señales
signal player_died
signal player_sliding
signal player_jumped

@export var move_speed : float = 8.0
@export var jump_force : float = 15.0
@export var gravity : float = 25.0
@export var slide_speed : float = 15.0
@export var slide_time : float = 0.7
@export var rotation_speed : float = 5.0

var current_speed : float
var is_sliding : bool = false
var slide_timer : float = 0.0
var can_move : bool = true
var is_alive : bool = true

# Crear colisiones si no existen
@onready var normal_collision = $CollisionShape3D
@onready var slide_collision = $SlideCollision

func _ready():
	# Añadir al grupo player
	add_to_group("player")
	
	# Crear colisiones si no existen
	setup_collisions()
	
	reset()
	print("Player ready en posición: ", position)

func setup_collisions():
	# Crear colisión normal si no existe
	if not normal_collision:
		normal_collision = CollisionShape3D.new()
		normal_collision.name = "CollisionShape3D"
		var capsule = CapsuleShape3D.new()
		capsule.height = 2.0
		capsule.radius = 0.5
		normal_collision.shape = capsule
		add_child(normal_collision)
	
	# Crear colisión para slide si no existe
	if not slide_collision:
		slide_collision = CollisionShape3D.new()
		slide_collision.name = "SlideCollision"
		var box = BoxShape3D.new()
		box.size = Vector3(1.0, 0.5, 1.0)
		slide_collision.shape = box
		slide_collision.disabled = true
		add_child(slide_collision)

func _physics_process(delta):
	if not can_move or not is_alive:
		return
	
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Movimiento horizontal
	handle_movement(delta)
	
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_sliding:
		velocity.y = jump_force
		emit_signal("player_jumped")
	
	# Deslizamiento
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:
		start_slide()
	elif is_sliding:
		update_slide(delta)
	
	# Aplicar movimiento
	move_and_slide()
	
	# Verificar muerte
	check_death()

func handle_movement(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
	
	if input_dir != Vector2.ZERO:
		velocity.x = input_dir.x * current_speed
		# Mantener movimiento hacia adelante constante
		velocity.z = -current_speed * 0.5
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * delta * 2)
		velocity.z = -current_speed * 0.5

func start_slide():
	is_sliding = true
	slide_timer = slide_time
	current_speed = slide_speed
	
	if normal_collision:
		normal_collision.disabled = true
	if slide_collision:
		slide_collision.disabled = false
	
	emit_signal("player_sliding")

func update_slide(delta):
	slide_timer -= delta
	if slide_timer <= 0:
		end_slide()

func end_slide():
	is_sliding = false
	current_speed = move_speed
	
	if normal_collision:
		normal_collision.disabled = false
	if slide_collision:
		slide_collision.disabled = true

func check_death():
	# Muerte por caída
	if position.y < -10:
		die()
		return
	
	# Muerte por colisión con obstáculos
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("obstacle"):
			die()
			return

func die():
	if not is_alive:
		return
	
	print("Player died!")
	is_alive = false
	can_move = false
	emit_signal("player_died")

func reset():
	is_alive = true
	can_move = true
	velocity = Vector3.ZERO
	position = Vector3(0, 1, 0)
	rotation = Vector3.ZERO
	current_speed = move_speed
	
	if normal_collision:
		normal_collision.disabled = false
	if slide_collision:
		slide_collision.disabled = true
	
	print("Player reset completado")

func enable_movement():
	can_move = true

func disable_movement():
	can_move = false
