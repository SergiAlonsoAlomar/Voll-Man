extends Node3D

class_name WorldChunk

signal chunk_exited

@export var chunk_length : float = 30.0
var move_speed : float = 5.0

func _ready():
	generate_platform_with_holes()
	generate_obstacles()
	generate_collectibles()

func _process(delta):
	position.z += move_speed * delta
	
	if position.z > chunk_length:
		emit_signal("chunk_exited")
		queue_free()

func generate_platform_with_holes():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Crear secciones de plataforma con huecos
	var section_length = 5.0
	var sections = int(chunk_length / section_length)
	
	for i in range(sections):
		# 80% de probabilidad de crear una plataforma en esta sección
		if rng.randf() > 0.2:
			var platform = MeshInstance3D.new()
			var mesh = BoxMesh.new()
			mesh.size = Vector3(8.0, 0.2, section_length)
			platform.mesh = mesh
			
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.4, 0.4, 0.4)
			platform.set_surface_override_material(0, material)
			
			platform.position = Vector3(0, 0, i * section_length + section_length/2)
			add_child(platform)
			platform.create_convex_collision()

func generate_obstacles():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(6):  # 6 obstáculos
		var obstacle = MeshInstance3D.new()
		obstacle.name = "Obstacle"
		
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(rng.randf_range(1.0, 2.0), 
							  rng.randf_range(1.0, 3.0), 
							  rng.randf_range(1.0, 2.0))
		obstacle.mesh = box_mesh
		
		var obstacle_material = StandardMaterial3D.new()
		obstacle_material.albedo_color = Color(0.9, 0.1, 0.1)
		obstacle.set_surface_override_material(0, obstacle_material)
		
		obstacle.position = Vector3(
			rng.randf_range(-3.5, 3.5),
			box_mesh.size.y/2,
			rng.randf_range(5.0, chunk_length - 5.0))
		
		add_child(obstacle)
		obstacle.create_convex_collision()
		obstacle.add_to_group("obstacle")

func generate_collectibles():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(10):  # 10 coleccionables
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
			rng.randf_range(-3.5, 3.5),
			0.5,
			rng.randf_range(5.0, chunk_length - 5.0))
		
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
