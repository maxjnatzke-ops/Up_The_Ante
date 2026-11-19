extends Camera3D

@export var CAMERA_SENS = 0.003

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * CAMERA_SENS
		rotation.x -= event.relative.y * CAMERA_SENS
		var maxDownDegree = -60
		var maxUpDegree = 80
		rotation.x = clamp(rotation.x, deg_to_rad(maxDownDegree), deg_to_rad(maxUpDegree))
