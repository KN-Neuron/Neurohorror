extends CharacterBody3D


const SPEED = 5.0
const RUNNING_SPEED = 15.0
const JUMP_VELOCITY = 4.5
const NORMAL_FOV = 75
const RUNNING_FOV = 85
const STAMINA_REGEN_COOLDOWN = 3

var mouse_sense = 0.1
var running_frame = 0
var exhaused = 0
var staminaCooldown = 0
var running = false

@onready var Head = $Capsule/Camera
@onready var Stamina = $Stamina
@onready var CAMERA_Y = 1 #$Capsule/Camera.position.y
@onready var Body = $Capsule

@export var menu:Control


func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu.visible = false
	
func _input(event):
	#get mouse input for camera rotation
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			Body.rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
			Head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
			Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		if event is InputEventKey and Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu.visible = true
	elif event is InputEventKey and Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menu.visible = false
	
	
var tspeed = SPEED

func _physics_process(delta: float) -> void:
	if staminaCooldown<=0:
		Stamina.value += delta
		if Stamina.value == Stamina.max_value:
			exhaused=false
			Stamina.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		staminaCooldown -=delta
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		running = Stamina.value>0 and Input.is_action_pressed("run") and !exhaused
		if running && !velocity.is_zero_approx():
			Stamina.value-=delta
			staminaCooldown=STAMINA_REGEN_COOLDOWN
			if Stamina.value==0:
				exhaused=true
				Stamina.modulate = Color(1.0, 0.0, 0.0, 1.0)
		
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3(0,1,0),Body.rotation.y)
		tspeed = clamp(tspeed+delta*20 if running else tspeed-delta*20, SPEED, RUNNING_SPEED)
		if direction:
			velocity.x = direction.x * tspeed
			velocity.z = direction.z * tspeed
		else:
			velocity.x = move_toward(velocity.x, 0, tspeed)
			velocity.z = move_toward(velocity.z, 0, tspeed)

	if velocity.is_zero_approx() && Head.position.y<CAMERA_Y+0.001:
		Head.position = Vector3(0,CAMERA_Y,0)
		Head.rotation.z=0
		running_frame = 0
	elif is_on_floor():
		if running:
			running_frame+=delta*10   
			Head.position.x = (ease(cos(running_frame)*0.5+0.5,-2)-0.5)*0.25   
			Head.position.y = CAMERA_Y-ease(abs(sin(running_frame)),3)*0.25
			Head.rotation.z = sin(running_frame)*0.008
		else:
			running_frame+=delta*4
			Head.position.y = CAMERA_Y-ease(abs(sin(running_frame)),3)*0.125
	
	Head.fov = clamp(Head.fov+delta*100,NORMAL_FOV,RUNNING_FOV) if running and !velocity.is_zero_approx() \
				else clamp(Head.fov-delta*100,NORMAL_FOV,RUNNING_FOV)
	
	move_and_slide()
