extends Node3D

signal chunk_exited

@export var chunk_length : float = 30.0
var move_speed : float = 5.0

func _ready():
	generate_platforms()
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

func generate_platforms():
	var base_platform = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(10.0, 0.2, chunk_length)
	base_platform.mesh = base_mesh
	
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.3, 0.3, 0.3)
	base_platform.set_surface_override_material(0, base_material)
	
	add_child(base_platform)
	base_platform.create_convex_collision()

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in range(3):
		var platform = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(rng.randf_range(2.0, 4.0), 0.2, rng.randf_range(3.0, 6.0))
		platform.mesh = mesh

		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.2, 0.5, 0.8)
		platform.set_surface_override_material(0, material)

		platform.position = Vector3(
			rng.randf_range(-3.0, 3.0),
			rng.randf_range(1.0, 3.0),
			rng.randf_range(10.0, chunk_length - 10.0))

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

		# Posición en el chunk
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
		collectible.queue_free()

		# Acceder al WorldManager por grupo
		var wm = get_tree().get_first_node_in_group("world_manager")
		if wm and wm.has_method("add_score"):
			wm.add_score(10)
