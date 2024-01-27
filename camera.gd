extends Camera2D

@export var speed := 400


func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		global_position.x -= speed * delta

	if Input.is_action_pressed("move_right"):
		global_position.x += speed * delta

	if Input.is_action_pressed("move_up"):
		global_position.y -= speed * delta

	if Input.is_action_pressed("move_down"):
		global_position.y += speed * delta
