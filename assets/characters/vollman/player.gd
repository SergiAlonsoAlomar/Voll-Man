extends CharacterBody3D

signal player_died
signal player_sliding
signal player_jumped

@export var move_speed : float = 5.0
@export var jump_force : float = 9.0
@export var gravity : float = 25.0
@export var slide_speed : float = 15.0
@export var slide_time : float = 0.7
@export var rotation_speed : float = 5.0

var current_speed : float
var is_sliding : bool = false
var slide_timer : float = 0.0
var can_move : bool = true
var is_alive : bool = true

@onready var anim_player: AnimationPlayer = $"voll-man-verde/AnimationPlayer"
@onready var normal_collision = $CollisionShape3D
@onready var slide_collision = $SlideCollision

func _ready():
	print("AnimationPlayer existe:", anim_player != null)
	if anim_player:
		print("Animaciones disponibles: ", anim_player.get_animation_list())
	add_to_group("player")
	setup_collisions()
	reset()
	print("Player ready en posición: ", position)

func setup_collisions():
	if not normal_collision:
		normal_collision = CollisionShape3D.new()
		normal_collision.name = "CollisionShape3D"
		var capsule = CapsuleShape3D.new()
		capsule.height = 2.0
		capsule.radius = 0.5
		normal_collision.shape = capsule
		add_child(normal_collision)

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

	if not is_on_floor():
		velocity.y -= gravity * delta

	handle_movement(delta)

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_sliding:
		velocity.y = jump_force
		emit_signal("player_jumped")

	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:
		start_slide()
	elif is_sliding:
		update_slide(delta)

	move_and_slide()
	update_animation()
	check_death()

func handle_movement(delta):
	var input_dir = Input.get_vector("move_right", "move_left", "", "")

	if input_dir != Vector2.ZERO:
		velocity.x = input_dir.x * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * delta * 2)

	velocity.z = 0

func update_animation():
	if not is_alive or not anim_player:
		return

	if not is_on_floor():
		if anim_player.current_animation != "Jump":
			anim_player.play("Jump")
	elif abs(velocity.x) > 0.1:
		if anim_player.current_animation != "Running":
			anim_player.play("Running")
	else:
		if anim_player.is_playing():
			anim_player.stop()

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
	if position.y < -10:
		die()
		return

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
