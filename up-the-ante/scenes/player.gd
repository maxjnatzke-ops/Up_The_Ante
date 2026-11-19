
extends CharacterBody3D

@onready var first_person_camera: Camera3D = $FirstPersonCamera
@onready var speed_label: Label = $CanvasLayer/SpeedLabel

# Movement settings
const SPEED = 5.0
const ACCELERATION = 8.0
const JUMP_VELOCITY = 4.5

# Sliding settings
const SLIDE_SPEED = 10.0
const SLIDE_DURATION = 0.7
const SLIDE_COOLDOWN = 1.0

var is_sliding = false
var slide_timer = 0.0
var slide_cooldown_timer = 0.0
var slide_direction = Vector3.ZERO
var slide_requested = false


# Detect a single press of Left Ctrl
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_CTRL and event.pressed and not event.echo:
			slide_requested = true


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get movement input
	var input_dir := Vector2.ZERO

	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Convert input to camera direction
	var direction := (
		first_person_camera.global_transform.basis
		* Vector3(input_dir.x, 0, input_dir.y)
	)

	direction.y = 0
	direction = direction.normalized()

	# Slide cooldown
	if slide_cooldown_timer > 0:
		slide_cooldown_timer -= delta

	# Start slide
	if (
		slide_requested
		and not is_sliding
		and slide_cooldown_timer <= 0
		and direction.length() > 0
		and is_on_floor()
	):
		is_sliding = true
		slide_timer = SLIDE_DURATION
		slide_direction = direction

	# Reset slide request
	slide_requested = false

	# Sliding movement
	if is_sliding:
		slide_timer -= delta

		velocity.x = slide_direction.x * SLIDE_SPEED
		velocity.z = slide_direction.z * SLIDE_SPEED

		if slide_timer <= 0:
			is_sliding = false
			slide_cooldown_timer = SLIDE_COOLDOWN

	# Normal movement
	else:
		if direction.length() > 0:
			velocity.x = move_toward(
				velocity.x,
				direction.x * SPEED,
				ACCELERATION * delta
			)

			velocity.z = move_toward(
				velocity.z,
				direction.z * SPEED,
				ACCELERATION * delta
			)
		else:
			# Stop immediately when movement keys are released
			velocity.x = 0
			velocity.z = 0

	# Move player
	move_and_slide()

	# Update speedometer
	update_speedometer()


func update_speedometer() -> void:
	# Horizontal speed
	var horizontal_speed = Vector2(
		velocity.x,
		velocity.z
	).length()

	# Vertical speed
	var vertical_speed = velocity.y

	# Total 3D speed
	var total_speed = velocity.length()

	# Movement status
	var movement_status = "STOPPED"

	if is_sliding:
		movement_status = "SLIDING"

	elif abs(vertical_speed) > 0.1:
		if vertical_speed > 0:
			movement_status = "JUMPING"
		else:
			movement_status = "FALLING"

	elif horizontal_speed > 0.1:
		movement_status = "MOVING"

	# Display speed information
	speed_label.text = "HORIZONTAL: %.2f m/s\nVERTICAL: %.2f m/s\nTOTAL: %.2f m/s\nSTATUS: %s" % [
		horizontal_speed,
		vertical_speed,
		total_speed,
		movement_status
	]
