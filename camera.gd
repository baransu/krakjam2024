extends Camera2D


func _unhandled_input(event: InputEvent) -> void:
	# todo: it's not working yet
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_zoom(get_zoom() * 1.1)
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_zoom(get_zoom() / 1.1)
