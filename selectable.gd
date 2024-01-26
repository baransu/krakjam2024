class_name Selectable
extends Area2D

signal on_hover_start
signal on_hover_end
signal on_select


func _ready() -> void:
	input_event.connect(on_input_event)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


func on_mouse_entered() -> void:
	on_hover_start.emit()


func on_mouse_exited() -> void:
	on_hover_end.emit()


func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			on_select.emit()
