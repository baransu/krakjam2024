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
signal game_over

var selected: Building
var buildings: Array[Building] = []

var buildable: Buildable
var seconds_elapsed := 18 * 60
var alkohol_access := false
var alkohol_access_price := 600

enum Tool { PLACE, DELETE, SELECT }

var tool: Tool = Tool.SELECT
var money = 1000


func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(add_time)
	add_child(timer)
	timer.start()


func add_time() -> void:
	var d_before = floori(seconds_elapsed / (60.0 * 24))
	var d_after = floori((seconds_elapsed + 1) / (60.0 * 24))

	seconds_elapsed += 1
	seconds_elapsed_changed.emit()

	if d_before != d_after:
		var staff_cost = 0
		for staff in get_tree().get_nodes_in_group("staff"):
			staff_cost += staff.staff_res.wage

		remove_money(staff_cost)


func select(b: Building) -> void:
	clear_selection()

	selected = b
	b.select()


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		reset_tool()

	if event.is_action_pressed("hack_money"):
		add_money(1000)


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
	if money < 0:
		trigger_game_over()


func buy_alkohol_access() -> void:
	if money < alkohol_access_price:
		return

	alkohol_access = true
	alkohol_access_changed.emit()
	remove_money(alkohol_access_price)


func get_hour() -> int:
	var h = roundi(seconds_elapsed / 60.0)
	return h


func trigger_game_over() -> void:
	get_tree().paused = true
	game_over.emit()


func restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	GameState.set_script(null)
	GameState.set_script(preload("res://game_state.gd"))
