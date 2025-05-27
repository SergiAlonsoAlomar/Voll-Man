extends Node3D

signal chunk_exited

@export var chunk_length : float = 30.0
var move_speed : float = 5.0

func _ready():
	generate_platforms()
	generate_obstacles()
	generate_collectibles()

func _process(delta):
	position.z += move_speed * delta
	
	if position.z > chunk_length:
		emit_signal("chunk_exited")
		queue_free()

func generate_platforms():
	# Plataforma base
	var base_platform = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(10.0, 0.2, chunk_length)
	base_platform.mesh = base_mesh
	
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.3, 0.3, 0.3)
	base_platform.set_surface_override_material(0, base_material)
	
	add_child(base_platform)
	base_platform.create_convex_collision()
	
	# Plataformas elevadas
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(3):  # 3 plataformas elevadas
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
	
	for i in range(4):  # 4 obstáculos
		var obstacle = MeshInstance3D.new()
		obstacle.name = "Obstacle"
		
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(rng.randf_range(0.5, 2.0), 
							  rng.randf_range(0.5, 3.0), 
							  rng.randf_range(0.5, 2.0))
		obstacle.mesh = box_mesh
		
		var obstacle_material = StandardMaterial3D.new()
		obstacle_material.albedo_color = Color(0.8, 0.2, 0.2)
		obstacle.set_surface_override_material(0, obstacle_material)
		
		obstacle.position = Vector3(
			rng.randf_range(-4.0, 4.0),
			box_mesh.size.y/2,
			rng.randf_range(10.0, chunk_length - 10.0))
		
		add_child(obstacle)
		obstacle.create_convex_collision()
		obstacle.add_to_group("obstacle")

func generate_collectibles():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(6):  # 6 coleccionables
		var collectible = MeshInstance3D.new()
		collectible.name = "Collectible"
		
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.3
		sphere_mesh.height = 0.6
		collectible.mesh = sphere_mesh
		
		var collectible_material = StandardMaterial3D.new()
		collectible_material.albedo_color = Color(1.0, 0.8, 0.2)
		collectible.set_surface_override_material(0, collectible_material)
		
		collectible.position = Vector3(
			rng.randf_range(-4.0, 4.0),
			rng.randf_range(0.5, 2.5),
			rng.randf_range(10.0, chunk_length - 10.0))
		
		add_child(collectible)
		collectible.create_convex_collision()
		
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
		if has_node("/root/WorldManager"):
			get_node("/root/WorldManager").add_score(10)
