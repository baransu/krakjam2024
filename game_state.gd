extends Node

signal tool_changed
signal building_destroyed(Building)
signal buildable_changed
signal building_empty(Building)
signal customer_left

var selected: Building
var buildings: Array[Building] = []

var buildable: Buildable

enum Tool { PLACE, DELETE, SELECT }

var tool: Tool = Tool.SELECT
var money = 0


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
	building_destroyed.emit(b)


func get_building_by_type(type: Building.Type, working: bool = true) -> Building:
	buildings.shuffle()
	for b in buildings:
		if b.type == type:
			if working && b.is_working():
				return b
			elif !working:
				return b

	return null


func set_buildable(b: Buildable) -> void:
	print("switching buildable")
	clear_selection()
	tool = Tool.PLACE
	tool_changed.emit()

	buildable = b
	buildable_changed.emit()


func add_money() -> void:
	money += 1
	print("money: ", money)
