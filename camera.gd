extends Camera2D

@export var speed := 400
@export var max_zoom := 3
@export var min_zoom := 0.5


func _process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		global_position.x -= speed * delta

	if Input.is_action_pressed("move_right"):
		global_position.x += speed * delta

	if Input.is_action_pressed("move_up"):
		global_position.y -= speed * delta

	if Input.is_action_pressed("move_down"):
		global_position.y += speed * delta


func _unhandled_input(event):
	var zoom_factor = 0.1
	if event.is_action_pressed("zoom_in"):
		zoom -= Vector2(zoom_factor, zoom_factor)
	if event.is_action_pressed("zoom_out"):
		zoom += Vector2(zoom_factor, zoom_factor)

	zoom = clamp(zoom, Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

	if event is InputEventMouseMotion && Input.is_action_pressed("right_click"):
		global_position -= event.relative
