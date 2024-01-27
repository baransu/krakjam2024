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


func get_building_for_product(product: Building.Product) -> Building:
	buildings.shuffle()
	for b in buildings:
		if b.product == product:
			match b.type:
				# always find checkout
				Building.Type.CHECKOUT:
					return b

				# other must be working and product should match
				_:
					if b.is_working():
						return b

	return null


func get_checkout_for_customer() -> Building:
	buildings.shuffle()
	for b in buildings:
		if b.type == Building.Type.CHECKOUT:
			return b

	return null


func get_building_for_staff(type: Building.Type) -> Building:
	buildings.shuffle()
	for b in buildings:
		if b.type == type:
			match type:
				# find checkout without staff
				Building.Type.CHECKOUT:
					if !b.is_working():
						return b

				_:
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
