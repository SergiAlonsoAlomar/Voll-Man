extends CharacterBody3D

# Señales implementadas correctamente
signal player_died     # Se emite en die()
signal player_sliding  # Se emite en start_slide()
signal player_jumped   # Se emite al saltar

@export var move_speed : float = 8.0
@export var jump_force : float = 10.0
@export var gravity : float = 20.0
@export var slide_speed : float = 15.0
@export var slide_time : float = 0.7
@export var rotation_speed : float = 5.0

var current_speed : float
var is_sliding : bool = false
var slide_timer : float = 0.0
var can_move : bool = true
var is_alive : bool = true

@onready var animation_player = $AnimationPlayer
@onready var slide_collision = $SlideCollision
@onready var normal_collision = $NormalCollision

func _ready():
	reset()

func _physics_process(delta):
	if not can_move or not is_alive:
		return
	
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_sliding:
		velocity.y = jump_force
		emit_signal("player_jumped")
	
	# Deslizamiento
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:
		start_slide()
	elif is_sliding:
		update_slide(delta)
	
	move_and_slide()
	
	# Muerte por caída o choque
	if position.y < -10:
		die()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("obstacle"):
			die()

func start_slide():
	is_sliding = true
	slide_timer = slide_time
	current_speed = slide_speed
	normal_collision.disabled = true
	slide_collision.disabled = false
	emit_signal("player_sliding")

func update_slide(delta):
	slide_timer -= delta
	if slide_timer <= 0:
		end_slide()

func end_slide():
	is_sliding = false
	current_speed = move_speed
	normal_collision.disabled = false
	slide_collision.disabled = true

func die():
	if not is_alive:
		return
	
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
	normal_collision.disabled = false
	slide_collision.disabled = true

func enable_movement():
	can_move = true

func disable_movement():
	can_move = false
