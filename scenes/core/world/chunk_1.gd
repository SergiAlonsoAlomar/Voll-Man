extends Node3D
class_name WorldChunk

signal chunk_exited

@export var chunk_length : float = 30.0
var move_speed : float = 5.0

func _ready():
	generate_platform()
	generate_obstacles()
	generate_collectibles()

func _process(delta):
	position.z -= move_speed * delta
	
	for c in collectible_list:
		if is_instance_valid(c):
			c.rotate_y(delta * 4.0)

	if position.z < -chunk_length:
		emit_signal("chunk_exited")
		queue_free()

func generate_platform():
	var platform = MeshInstance3D.new()
	var plane_mesh = BoxMesh.new()
	plane_mesh.size = Vector3(10.0, 0.2, chunk_length)
	platform.mesh = plane_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.1, 0.1)
	platform.set_surface_override_material(0, material)
	
	add_child(platform)
	platform.create_convex_collision()

func generate_obstacles():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in range(4):
		var obstacle = StaticBody3D.new()

		# Malla visual
		var mesh_instance = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(rng.randf_range(0.5, 1.5), rng.randf_range(1.0, 2.5), rng.randf_range(0.5, 1.5))
		mesh_instance.mesh = mesh

		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.8, 0.2, 0.2)
		mesh_instance.set_surface_override_material(0, material)

		obstacle.add_child(mesh_instance)

		# Colisión
		var shape = BoxShape3D.new()
		shape.size = mesh.size

		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = shape

		obstacle.add_child(collision_shape)

		# Colocar obstaculos en el chunk
		obstacle.position = Vector3(
			rng.randf_range(-4.0, 4.0),
			shape.size.y / 2.0,
			rng.randf_range(5.0, chunk_length - 5.0)
		)

		# Añadir al grupo para detección
		obstacle.add_to_group("obstacle")
		add_child(obstacle)

var collectible_list: Array = []

func generate_collectibles():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	collectible_list.clear()

	for i in range(6):
		var collectible_scene = preload("res://assets/characters/collectibles/lata-Voll.glb")
		var collectible = collectible_scene.instantiate()
		collectible.name = "Collectible"
		collectible.scale = Vector3(0.2, 0.2, 0.2)
		collectible.rotation_degrees.z = 15

		collectible.position = Vector3(
			rng.randf_range(-4.0, 4.0),
			rng.randf_range(0.5, 2.0),
			rng.randf_range(5.0, chunk_length - 5.0)
		)

		add_child(collectible)
		collectible_list.append(collectible)

		# Área de colisión
		var area = Area3D.new()
		var collision = CollisionShape3D.new()
		collision.shape = SphereShape3D.new()
		collision.shape.radius = 0.5
		area.add_child(collision)
		collectible.add_child(area)

		area.body_entered.connect(_on_collectible_collected.bind(collectible))

func _on_collectible_collected(body, collectible):
	if body.name == "Player":
		# Reproducir sonido al recoger la lata
		var sfx = AudioStreamPlayer.new()
		sfx.stream = preload("res://assets/audio/lataSound.mp3")
		sfx.pitch_scale = randf_range(0.95, 1.05)
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

		# Eliminar el colectible de la escena
		collectible.queue_free()

		# Sumar puntuación al jugador
		var wm = get_tree().get_first_node_in_group("world_manager")
		if wm and wm.has_method("add_score"):
			wm.add_score(10)
