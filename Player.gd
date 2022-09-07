extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var Paused : bool = false

func _ready():
	Global.Player = self

func _input(event):
	if !Paused:
		if event is InputEventMouseMotion:
			var Spin : Vector2 = event.relative * 0.01
			rotation.y -= Spin.x
			$Camera.rotation.x = clamp($Camera.rotation.x - Spin.y, -deg_to_rad(85), deg_to_rad(85))

func _physics_process(delta):
	if Paused:
		$Label.visible = false
	else:
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var input_dir = Input.get_vector("Left", "Right", "Forw", "Back")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		$Label.visible = false
		if $Camera/Ray.is_colliding():
			var Collider : Node3D = $Camera/Ray.get_collider()
			if Collider.has_method("GetPrompt"):
				$Label.text = Collider.GetPrompt()
				$Label.visible = true
			if Input.is_action_just_pressed("Interact") && Collider.has_method("Interact"):
				Collider.Interact()
		
		move_and_slide()

func SetPaused(New : bool):
	Paused = New
	$Label.visible = !Paused

func SetMouseLock(New : bool):
	if New:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
