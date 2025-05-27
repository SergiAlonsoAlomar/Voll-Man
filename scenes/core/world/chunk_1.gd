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
	position.z += move_speed * delta
	
	if position.z > chunk_length:
		emit_signal("chunk_exited")
		queue_free()

func generate_platform():
	var platform = MeshInstance3D.new()
	var plane_mesh = BoxMesh.new()
	plane_mesh.size = Vector3(10.0, 0.2, chunk_length)
	platform.mesh = plane_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.3, 0.3)
	platform.set_surface_override_material(0, material)
	
	add_child(platform)
	platform.create_convex_collision()

func generate_obstacles():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(5):
		var obstacle = MeshInstance3D.new()
		obstacle.name = "Obstacle"
		
		var is_cylinder = rng.randf() > 0.5
		var obstacle_height = 0.0
		
		if is_cylinder:
			var cylinder_mesh = CylinderMesh.new()
			cylinder_mesh.top_radius = rng.randf_range(0.5, 1.0)
			cylinder_mesh.bottom_radius = rng.randf_range(0.5, 1.0)
			cylinder_mesh.height = rng.randf_range(1.0, 2.5)
			obstacle.mesh = cylinder_mesh
			obstacle_height = cylinder_mesh.height / 2
		else:
			var box_mesh = BoxMesh.new()
			box_mesh.size = Vector3(rng.randf_range(0.8, 1.5), rng.randf_range(0.8, 2.0), rng.randf_range(0.8, 1.5))
			obstacle.mesh = box_mesh
			obstacle_height = box_mesh.size.y / 2
		
		var obstacle_material = StandardMaterial3D.new()
		obstacle_material.albedo_color = Color(rng.randf(), rng.randf(), rng.randf())
		obstacle.set_surface_override_material(0, obstacle_material)
		
		obstacle.position = Vector3(rng.randf_range(-4.0, 4.0), obstacle_height, rng.randf_range(5.0, chunk_length - 5.0))
		
		add_child(obstacle)
		obstacle.create_convex_collision()
		obstacle.add_to_group("obstacle")

func generate_collectibles():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(8):
		var collectible = MeshInstance3D.new()
		collectible.name = "Collectible"
		
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.3
		sphere_mesh.height = 0.6
		collectible.mesh = sphere_mesh
		
		var collectible_material = StandardMaterial3D.new()
		collectible_material.albedo_color = Color(1.0, 0.8, 0.2)
		collectible.set_surface_override_material(0, collectible_material)
		
		collectible.position = Vector3(rng.randf_range(-4.0, 4.0), 0.5, rng.randf_range(5.0, chunk_length - 5.0))
		
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
		var world_manager = get_node_or_null("/root/WorldManager")
		if world_manager:
			world_manager.add_score(10)
