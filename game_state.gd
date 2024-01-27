extends Node

signal tool_changed
signal building_destroyed(Building)
signal buildable_changed
signal building_empty(Building)
signal customer_left
signal seconds_elapsed_changed
signal money_changed(int)
signal staff_changed
signal alkohol_access_changed
signal building_selected(Building)
signal building_deselected(Building)
signal building_changed(Building)

var selected: Building
var buildings: Array[Building] = []

var buildable: Buildable
var seconds_elapsed := 12 * 60  # noon
var alkohol_access := true
var alkohol_access_price := 1000

enum Tool { PLACE, DELETE, SELECT }

var tool: Tool = Tool.SELECT
var money = 1000


func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = 1
	timer.timeout.connect(add_time)
	add_child(timer)
	timer.start()


func add_time() -> void:
	seconds_elapsed += 1
	seconds_elapsed_changed.emit()


func select(b: Building) -> void:
	clear_selection()

	selected = b
	b.select()


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		reset_tool()


func reset_tool() -> void:
	clear_selection()

	if tool != Tool.SELECT:
		tool = Tool.SELECT
		tool_changed.emit()


func delete_tool() -> void:
	clear_selection()
	tool = Tool.DELETE
	tool_changed.emit()


func clear_selection() -> void:
	if is_instance_valid(selected):
		selected.deselect()
		selected = null


func delete(b: Building) -> void:
	add_money(b.get_delete_cost())
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
	clear_selection()
	tool = Tool.PLACE
	tool_changed.emit()

	buildable = b
	buildable_changed.emit()


func add_money(delta: int = 1) -> void:
	money += delta
	money_changed.emit(money)


func remove_money(delta: int = 1) -> void:
	money -= delta
	money_changed.emit(-delta)


func buy_alkohol_access() -> void:
	alkohol_access = true
	alkohol_access_changed.emit()
	remove_money(alkohol_access_price)
