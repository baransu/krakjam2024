extends Node

signal tool_changed

var selected: Building

var buildings: Array[Building] = []

enum Tool { PLACE, DELETE, SELECT }

var tool: Tool = Tool.PLACE


func select(b: Building) -> void:
	clear_selection()

	selected = b
	b.select()


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		clear_selection()

		if tool != Tool.SELECT:
			tool = Tool.SELECT
			tool_changed.emit()

	if event.is_action_pressed("tool_place"):
		clear_selection()
		tool = Tool.PLACE
		tool_changed.emit()

	if event.is_action_pressed("tool_delete"):
		clear_selection()
		tool = Tool.DELETE
		tool_changed.emit()


func clear_selection() -> void:
	if is_instance_valid(selected):
		selected.deselect()
		selected = null


func delete(b: Building) -> void:
	b.queue_free()
	buildings.erase(b)
