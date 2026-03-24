extends CharacterBody3D

var speed = 3.0
var wander_radius = 30.0 
var idle_time = 2.0

@onready var nav_agent = $NavigationAgent3D
@onready var idle_timer = $Timer

var is_idling = false

func _ready():
	idle_timer.wait_time = idle_time
	idle_timer.one_shot = true
	idle_timer.timeout.connect(_on_timer_timeout)
	start_idling()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 10 * delta

	if is_idling:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	var pox_xz = Vector2(global_position.x, global_position.z)
	var target_pos_xz = Vector2(nav_agent.target_position.x, nav_agent.target_position.z)
	if pox_xz.distance_to(target_pos_xz) < 1.5:
		print("DEBUG (status): Idling")
		start_idling()
		return
		
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = Vector3()
	direction.x = next_path_pos.x - global_position.x
	direction.z = next_path_pos.z - global_position.z
	if direction.length() > 0.01:
		direction = direction.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		var target_rotation = Quaternion.from_euler(Vector3(0, atan2(direction.x, direction.z), 0))
		var current_rotation = global_transform.basis.get_rotation_quaternion()
		var new_rotation = current_rotation.slerp(target_rotation, 10.0 * delta)
		global_transform.basis = Basis(new_rotation)
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func pick_random_target():
	var map_rid = nav_agent.get_navigation_map()
	
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius), 
		0, 
		randf_range(-wander_radius, wander_radius)
	)
	var random_target = global_position + random_offset
	var correct_target = NavigationServer3D.map_get_closest_point(map_rid, random_target)
	
	nav_agent.target_position = correct_target
	is_idling = false
	print("DEBUG (target): ", correct_target)

func start_idling():
	is_idling = true
	velocity.x = 0
	velocity.z = 0
	idle_timer.start()

func _on_timer_timeout():
	pick_random_target()
